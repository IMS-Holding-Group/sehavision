"""
سكربت إضافة صور التدريب إلى قاعدة البيانات - SehaVision
Script to add training images to database
"""
import sqlite3
import hashlib
from pathlib import Path
from PIL import Image
from datetime import datetime
import argparse
from config.config import Config

class TrainingImageManager:
    
    def __init__(self, db_path: str = None, data_dir: str = None):
        self.config = Config()
        self.db_path = db_path or self.config.DATABASE_PATH
        # استخدام المسار المطلق من Config أو المسار المحدد
        if data_dir:
            self.data_dir = Path(data_dir)
        else:
            self.data_dir = Path(self.config.TRAINING_DATA_FOLDER)
        self.connection = None
    
    def connect(self):
        """الاتصال بقاعدة البيانات"""
        try:
            # إنشاء قاعدة البيانات إن لم تكن موجودة
            Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
            
            self.connection = sqlite3.connect(self.db_path)
            self.connection.row_factory = sqlite3.Row
            
            # إنشاء جدول صور التدريب إن لم يكن موجوداً
            self.create_table()
            
            print(f"✅ تم الاتصال بقاعدة البيانات: {self.db_path}")
            return True
        except Exception as e:
            print(f"❌ خطأ في الاتصال بقاعدة البيانات: {e}")
            return False
    
    def create_table(self):
        """إنشاء جدول صور التدريب"""
        cursor = self.connection.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS training_images (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                image_path TEXT NOT NULL,
                drug_name TEXT NOT NULL,
                file_size INTEGER,
                image_width INTEGER,
                image_height INTEGER,
                file_hash TEXT UNIQUE,
                added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                is_active INTEGER DEFAULT 1
            )
        """)
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_drug_name ON training_images(drug_name)")
        cursor.execute("CREATE INDEX IF NOT EXISTS idx_file_hash ON training_images(file_hash)")
        self.connection.commit()
        cursor.close()
    
    def disconnect(self):
        """إغلاق الاتصال"""
        if self.connection:
            self.connection.close()
            print("✅ تم إغلاق الاتصال")
    
    def calculate_file_hash(self, file_path: Path) -> str:
        """حساب hash للملف"""
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    
    def is_valid_image(self, image_path: Path) -> bool:
        """التحقق من صحة الصورة"""
        try:
            with Image.open(image_path) as img:
                img.verify()
            # محاولة فتح مرة أخرى للتأكد
            img = Image.open(image_path)
            img.load()
            return True
        except Exception:
            return False
    
    def get_image_info(self, image_path: Path) -> dict:
        """الحصول على معلومات الصورة"""
        try:
            with Image.open(image_path) as img:
                width, height = img.size
                file_size = image_path.stat().st_size
                return {'width': width, 'height': height, 'file_size': file_size}
        except Exception as e:
            print(f"⚠️ خطأ في قراءة الصورة {image_path}: {e}")
            return {'width': None, 'height': None, 'file_size': image_path.stat().st_size if image_path.exists() else 0}
    
    def image_exists(self, file_hash: str) -> bool:
        """التحقق من وجود الصورة"""
        cursor = self.connection.cursor()
        cursor.execute("SELECT id FROM training_images WHERE file_hash = ?", (file_hash,))
        result = cursor.fetchone()
        cursor.close()
        return result is not None
    
    def add_image(self, image_path: Path, drug_name: str) -> bool:
        """إضافة صورة إلى قاعدة البيانات"""
        try:
            file_hash = self.calculate_file_hash(image_path)
            
            if self.image_exists(file_hash):
                print(f"⏭️ الصورة موجودة: {image_path.name}")
                return False
            
            image_info = self.get_image_info(image_path)
            relative_path = str(image_path.relative_to(self.data_dir))
            
            cursor = self.connection.cursor()
            cursor.execute("""
                INSERT INTO training_images 
                (image_path, drug_name, file_size, image_width, image_height, file_hash, added_at, is_active)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                relative_path,
                drug_name,
                image_info['file_size'],
                image_info['width'],
                image_info['height'],
                file_hash,
                datetime.now(),
                1
            ))
            self.connection.commit()
            cursor.close()
            
            print(f"✅ تمت إضافة: {image_path.name} ({drug_name})")
            return True
            
        except Exception as e:
            print(f"❌ خطأ في إضافة {image_path}: {e}")
            return False
    
    def scan_and_add_images(self) -> dict:
        """فحص مجلد التدريب وإضافة الصور"""
        stats = {'total_found': 0, 'added': 0, 'skipped': 0, 'by_drug': {}}
        
        print(f"📂 المسار المستخدم: {self.data_dir.absolute()}")
        
        if not self.data_dir.exists():
            print(f"❌ المجلد غير موجود: {self.data_dir}")
            return stats
        
        print(f"\n🔍 فحص مجلد: {self.data_dir}\n")
        
        # فحص كل مجلد دواء
        for drug_dir in self.data_dir.iterdir():
            if not drug_dir.is_dir():
                continue
            
            drug_name = drug_dir.name
            stats['by_drug'][drug_name] = {'found': 0, 'added': 0, 'skipped': 0}
            
            print(f"📁 {drug_name}:")
            
            # البحث عن الصور
            images = []
            for ext in ['.jpg', '.jpeg', '.png', '.webp', '.bmp']:
                images.extend(drug_dir.glob(f'*{ext}'))
                images.extend(drug_dir.glob(f'*{ext.upper()}'))
            
            stats['by_drug'][drug_name]['found'] = len(images)
            stats['total_found'] += len(images)
            
            print(f"   📸 عدد الصور: {len(images)}")
            
            # إضافة الصور (تخطي التالفة)
            for image_path in images:
                if not self.is_valid_image(image_path):
                    print(f"⚠️ تخطي صورة تالفة: {image_path.name}")
                    stats['skipped'] += 1
                    stats['by_drug'][drug_name]['skipped'] += 1
                    continue
                
                if self.add_image(image_path, drug_name):
                    stats['added'] += 1
                    stats['by_drug'][drug_name]['added'] += 1
                else:
                    stats['skipped'] += 1
                    stats['by_drug'][drug_name]['skipped'] += 1
        
        return stats
    
    def get_statistics(self) -> dict:
        """الحصول على إحصائيات"""
        cursor = self.connection.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM training_images WHERE is_active = 1")
        total = cursor.fetchone()[0]
        
        cursor.execute("""
            SELECT drug_name, COUNT(*) as count 
            FROM training_images 
            WHERE is_active = 1 
            GROUP BY drug_name
            ORDER BY count DESC
        """)
        by_drug = {row[0]: row[1] for row in cursor.fetchall()}
        
        cursor.close()
        
        return {'total': total, 'by_drug': by_drug}
    
    def print_statistics(self):
        """طباعة الإحصائيات"""
        stats = self.get_statistics()
        
        print("\n" + "=" * 60)
        print("📊 إحصائيات قاعدة البيانات")
        print("=" * 60)
        print(f"إجمالي الصور: {stats['total']}")
        print("\n📁 حسب الدواء:")
        for drug, count in stats['by_drug'].items():
            print(f"   - {drug}: {count} صورة")
        print("=" * 60)


def main():
    parser = argparse.ArgumentParser(description='إضافة صور التدريب إلى قاعدة البيانات')
    parser.add_argument('--data-dir', type=str, default=None, help='مسار مجلد التدريب')
    parser.add_argument('--db-path', type=str, default=None, help='مسار قاعدة البيانات')
    parser.add_argument('--stats-only', action='store_true', help='عرض الإحصائيات فقط')
    
    args = parser.parse_args()
    
    manager = TrainingImageManager(db_path=args.db_path, data_dir=args.data_dir)
    
    if not manager.connect():
        return
    
    try:
        if args.stats_only:
            manager.print_statistics()
        else:
            print("=" * 60)
            print("🚀 بدء إضافة صور التدريب")
            print("=" * 60)
            
            stats = manager.scan_and_add_images()
            
            print("\n📊 النتائج:")
            print(f"   - إجمالي الصور: {stats['total_found']}")
            print(f"   - تمت الإضافة: {stats['added']}")
            print(f"   - تم التخطي: {stats['skipped']}")
            
            manager.print_statistics()
            
    finally:
        manager.disconnect()


if __name__ == "__main__":
    main()
