"""
Database Service for Medicine Search
خدمة قاعدة البيانات للبحث عن الأدوية
"""
import sqlite3
import json
import os
from typing import List, Dict, Optional
from config.config import Config

class DatabaseService:
    def __init__(self):
        self.config = Config()
        self.db_path = self.config.DATABASE_PATH
    
    def _get_connection(self):
        """Get database connection"""
        if not os.path.exists(self.db_path):
            raise FileNotFoundError(f"Database not found at {self.db_path}")
        return sqlite3.connect(self.db_path)
    
    def search_medicines(self, search_text: str, limit: int = 10) -> List[Dict]:
        """
        Search medicines in database
        البحث عن الأدوية في قاعدة البيانات
        """
        if not search_text or len(search_text.strip()) < 2:
            return []
        
        try:
            conn = self._get_connection()
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            # Clean search text
            search_lower = search_text.lower().strip()
            words = [w for w in search_lower.split() if len(w) > 2]
            
            if not words:
                return []
            
            # Build search query - search in both English and Arabic fields
            query = """
                SELECT * FROM medicines 
                WHERE 
                    LOWER(name) LIKE ? OR
                    LOWER(name_ar) LIKE ? OR
                    LOWER(brand) LIKE ? OR
                    LOWER(brand_ar) LIKE ? OR
                    LOWER(description) LIKE ? OR
                    LOWER(description_ar) LIKE ?
                ORDER BY 
                    CASE 
                        WHEN LOWER(name) = ? THEN 1
                        WHEN LOWER(name_ar) = ? THEN 2
                        WHEN LOWER(name) LIKE ? THEN 3
                        WHEN LOWER(name_ar) LIKE ? THEN 4
                        WHEN LOWER(brand) = ? THEN 5
                        WHEN LOWER(brand_ar) = ? THEN 6
                        ELSE 7
                    END
                LIMIT ?
            """
            
            # Prepare parameters
            search_pattern = f"%{search_lower}%"
            first_word_pattern = f"%{words[0]}%"
            
            params = [
                search_pattern, search_pattern, search_pattern, search_pattern,
                search_pattern, search_pattern,  # WHERE clause
                search_lower, search_lower,  # Exact matches
                first_word_pattern, first_word_pattern,  # Starts with
                search_lower, search_lower,  # Brand exact
                limit
            ]
            
            cursor.execute(query, params)
            rows = cursor.fetchall()
            
            # Convert rows to dictionaries
            medicines = []
            for row in rows:
                medicine = dict(row)
                # Parse JSON fields
                if medicine.get('interactions'):
                    try:
                        medicine['interactions'] = json.loads(medicine['interactions'])
                    except:
                        medicine['interactions'] = []
                
                if medicine.get('image_paths'):
                    try:
                        medicine['image_paths'] = json.loads(medicine['image_paths'])
                    except:
                        medicine['image_paths'] = []
                
                medicines.append(medicine)
            
            conn.close()
            return medicines
            
        except Exception as e:
            print(f"Database search error: {e}")
            return []
    
    def get_medicine_by_id(self, medicine_id: int) -> Optional[Dict]:
        """Get medicine by ID"""
        try:
            conn = self._get_connection()
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute("SELECT * FROM medicines WHERE id = ?", (medicine_id,))
            row = cursor.fetchone()
            
            if row:
                medicine = dict(row)
                # Parse JSON fields
                if medicine.get('interactions'):
                    try:
                        medicine['interactions'] = json.loads(medicine['interactions'])
                    except:
                        medicine['interactions'] = []
                
                if medicine.get('image_paths'):
                    try:
                        medicine['image_paths'] = json.loads(medicine['image_paths'])
                    except:
                        medicine['image_paths'] = []
                
                conn.close()
                return medicine
            
            conn.close()
            return None
            
        except Exception as e:
            print(f"Database get error: {e}")
            return None

