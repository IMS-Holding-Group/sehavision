"""
سكربت إضافة الأدوية المدربة إلى قاعدة البيانات
Script to add trained drugs to database
"""
import sqlite3
import json
import os
from pathlib import Path
from config.config import Config

class TrainedDrugsAdder:
    
    def __init__(self):
        self.config = Config()
        self.db_path = self.config.DATABASE_PATH
        
        # معلومات الأدوية المدربة
        self.trained_drugs = {
            'sertraline': {
                'name': 'Sertraline',
                'name_ar': 'سيرترالين',
                'brand': 'Zoloft',
                'brand_ar': 'زولوفت',
                'dosage': '50mg, 100mg',
                'description': 'Sertraline is an antidepressant medication used to treat depression, anxiety disorders, and obsessive-compulsive disorder.',
                'description_ar': 'سيرترالين هو دواء مضاد للاكتئاب يستخدم لعلاج الاكتئاب واضطرابات القلق واضطراب الوسواس القهري.',
                'instructions': 'Take as directed by your doctor, usually once daily with or without food.',
                'warnings': 'May cause drowsiness, nausea, or sexual side effects. Do not stop taking suddenly.',
                'interactions': ['MAO inhibitors', 'Warfarin', 'NSAIDs']
            },
            'cortef': {
                'name': 'Cortef',
                'name_ar': 'كورتيف',
                'brand': 'Cortef',
                'brand_ar': 'كورتيف',
                'dosage': '5mg, 10mg, 20mg',
                'description': 'Cortef (hydrocortisone) is a corticosteroid used to treat inflammation and autoimmune conditions.',
                'description_ar': 'كورتيف (هيدروكورتيزون) هو كورتيكوستيرويد يستخدم لعلاج الالتهابات والحالات المناعية الذاتية.',
                'instructions': 'Take exactly as prescribed by your doctor. Do not stop taking suddenly.',
                'warnings': 'May cause weight gain, high blood pressure, or mood changes. Long-term use requires medical supervision.',
                'interactions': ['Warfarin', 'Diabetes medications', 'NSAIDs']
            },
            'cetralon': {
                'name': 'Cetralon',
                'name_ar': 'سيترالون',
                'brand': 'Cetralon',
                'brand_ar': 'سيترالون',
                'dosage': 'Varies',
                'description': 'Cetralon medication information.',
                'description_ar': 'معلومات دواء سيترالون.',
                'instructions': 'Take as directed by your doctor.',
                'warnings': 'Consult your doctor for specific warnings.',
                'interactions': []
            },
            'panadol_extra': {
                'name': 'Panadol Extra',
                'name_ar': 'بنادول إكسترا',
                'brand': 'Panadol',
                'brand_ar': 'بنادول',
                'dosage': '500mg + 65mg caffeine',
                'description': 'Panadol Extra is a pain reliever containing paracetamol and caffeine for enhanced pain relief.',
                'description_ar': 'بنادول إكسترا هو مسكن للألم يحتوي على باراسيتامول وكافيين لتسكين الألم المحسن.',
                'instructions': 'Take 1-2 tablets every 4-6 hours as needed. Do not exceed 8 tablets in 24 hours.',
                'warnings': 'Do not exceed recommended dose. May cause liver damage if taken in excess.',
                'interactions': ['Warfarin', 'Alcohol']
            },
            'paracetamol': {
                'name': 'Paracetamol',
                'name_ar': 'باراسيتامول',
                'brand': 'Panadol',
                'brand_ar': 'بنادول',
                'dosage': '500mg',
                'description': 'Paracetamol is a pain reliever and fever reducer.',
                'description_ar': 'الباراسيتامول هو مسكن للألم وخافض للحرارة.',
                'instructions': 'Take 1-2 tablets every 4-6 hours as needed. Do not exceed 8 tablets in 24 hours.',
                'warnings': 'Do not exceed recommended dose. May cause liver damage if taken in excess.',
                'interactions': ['Warfarin', 'Alcohol']
            }
        }
    
    def connect(self):
        """الاتصال بقاعدة البيانات"""
        try:
            Path(self.db_path).parent.mkdir(parents=True, exist_ok=True)
            return sqlite3.connect(self.db_path)
        except Exception as e:
            print(f"❌ خطأ في الاتصال: {e}")
            return None
    
    def drug_exists(self, cursor, name: str) -> bool:
        """التحقق من وجود الدواء"""
        cursor.execute("SELECT id FROM medicines WHERE LOWER(name) = ?", (name.lower(),))
        return cursor.fetchone() is not None
    
    def add_drug(self, conn, drug_key: str, drug_info: dict) -> bool:
        """إضافة دواء إلى قاعدة البيانات"""
        cursor = conn.cursor()
        
        try:
            # التحقق من وجود الدواء
            if self.drug_exists(cursor, drug_info['name']):
                print(f"⏭️ الدواء موجود مسبقاً: {drug_info['name']}")
                return False
            
            # إضافة الدواء (استخدام الأعمدة الموجودة فقط)
            cursor.execute("""
                INSERT INTO medicines 
                (name, brand, dosage, instructions, warnings, interactions)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (
                drug_info['name'],
                drug_info['brand'],
                drug_info['dosage'],
                drug_info.get('instructions', ''),
                drug_info.get('warnings', ''),
                json.dumps(drug_info.get('interactions', []))
            ))
            
            conn.commit()
            print(f"✅ تمت إضافة: {drug_info['name']}")
            return True
            
        except Exception as e:
            print(f"❌ خطأ في إضافة {drug_info['name']}: {e}")
            return False
        finally:
            cursor.close()
    
    def add_all_trained_drugs(self):
        """إضافة جميع الأدوية المدربة"""
        conn = self.connect()
        if not conn:
            return
        
        print("=" * 60)
        print("🚀 بدء إضافة الأدوية المدربة إلى قاعدة البيانات")
        print("=" * 60)
        
        added = 0
        skipped = 0
        
        for drug_key, drug_info in self.trained_drugs.items():
            if self.add_drug(conn, drug_key, drug_info):
                added += 1
            else:
                skipped += 1
        
        conn.close()
        
        print("\n" + "=" * 60)
        print("📊 النتائج:")
        print(f"   - تمت الإضافة: {added}")
        print(f"   - تم التخطي: {skipped}")
        print("=" * 60)


def main():
    adder = TrainedDrugsAdder()
    adder.add_all_trained_drugs()


if __name__ == "__main__":
    main()
