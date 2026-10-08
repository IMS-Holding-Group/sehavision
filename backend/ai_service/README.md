# دليل التدريب - SehaVision

## طريقة إضافة الصور الجديدة وتدريب النموذج

### 1. إضافة الصور إلى قاعدة البيانات

```bash
cd backend/ai_service
python add_training_images_to_db.py
```

### 2. إضافة الأدوية المدربة إلى قاعدة البيانات

**مهم:** بعد التدريب، يجب إضافة الأدوية المدربة إلى قاعدة البيانات:

```bash
python add_trained_drugs_to_db.py
```

### 3. تدريب النموذج

```bash
python train_model.py --data-dir training_data --epochs 50 --batch-size 32
```

### 4. عرض إحصائيات البيانات

```bash
python add_training_images_to_db.py --stats-only
```

---

## هيكل المجلدات

```
training_data/
├── paracetamol/
│   ├── paracetamol_001.jpg
│   ├── paracetamol_002.jpg
│   └── ...
├── panadol_extra/
│   ├── panadol_001.jpg
│   └── ...
└── ...
```

ضع صورك في مجلدات الأدوية ثم شغل السكربتات أعلاه.
