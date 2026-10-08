const db = require('../config/database');
const cron = require('node-cron');

class ReminderScheduler {
    constructor() {
        this.isRunning = false;
        this.checkInterval = null;
    }

    /**
     * بدء خدمة جدولة التذكيرات
     */
    start() {
        if (this.isRunning) {
            console.log('⚠️ خدمة الجدولة تعمل بالفعل');
            return;
        }

        this.isRunning = true;
        console.log('🔔 بدء خدمة جدولة التذكيرات...');

        // فحص التذكيرات كل دقيقة
        // cron expression: '*/1 * * * *' = كل دقيقة
        this.checkInterval = cron.schedule('*/1 * * * *', () => {
            this.checkAndProcessReminders();
        });

        // فحص فوري عند البدء
        this.checkAndProcessReminders();

        console.log('✅ خدمة جدولة التذكيرات بدأت بنجاح');
    }

    /**
     * إيقاف خدمة جدولة التذكيرات
     */
    stop() {
        if (!this.isRunning) {
            return;
        }

        if (this.checkInterval) {
            this.checkInterval.stop();
            this.checkInterval = null;
        }

        this.isRunning = false;
        console.log('🛑 تم إيقاف خدمة جدولة التذكيرات');
    }

    /**
     * فحص ومعالجة التذكيرات المستحقة
     */
    checkAndProcessReminders() {
        const now = new Date();
        const nowISO = now.toISOString();

        // البحث عن التذكيرات المستحقة في الدقيقة الحالية
        // نفحص التذكيرات التي يجب أن تُرسل في الدقيقة الحالية (±30 ثانية)
        const query = `
            SELECT r.*, m.name as medicine_name, m.brand as medicine_brand, m.dosage,
                   u.email, u.name as user_name
            FROM reminders r
            JOIN medicines m ON r.medicine_id = m.id
            JOIN users u ON r.user_id = u.id
            WHERE r.is_active = 1
            AND r.scheduled_time <= datetime('now', '+30 seconds')
            AND r.scheduled_time >= datetime('now', '-30 seconds')
            ORDER BY r.scheduled_time
        `;

        db.all(query, [], (err, reminders) => {
            if (err) {
                console.error('❌ خطأ في فحص التذكيرات:', err);
                return;
            }

            if (reminders && reminders.length > 0) {
                console.log(`📬 تم العثور على ${reminders.length} تذكير مستحق`);
                reminders.forEach(reminder => {
                    this.processReminder(reminder);
                });
            }
        });
    }

    /**
     * معالجة تذكير واحد
     */
    processReminder(reminder) {
        console.log(`🔔 معالجة التذكير ID: ${reminder.id} - ${reminder.title}`);
        console.log(`   المستخدم: ${reminder.user_name} (${reminder.email})`);
        console.log(`   الدواء: ${reminder.medicine_name} (${reminder.brand})`);
        console.log(`   الوقت المحدد: ${reminder.scheduled_time}`);

        // هنا يمكنك إضافة منطق إرسال الإشعارات
        // على سبيل المثال: إرسال push notification عبر FCM أو OneSignal
        this.sendNotification(reminder);

        // تحديث حالة التذكير بناءً على التكرار
        this.updateReminderAfterProcessing(reminder);
    }

    /**
     * إرسال إشعار للتذكير
     */
    sendNotification(reminder) {
        // TODO: إضافة منطق إرسال الإشعارات الفعلية
        // يمكن استخدام:
        // - Firebase Cloud Messaging (FCM)
        // - OneSignal
        // - أو أي خدمة إشعارات أخرى

        console.log(`📱 إشعار: ${reminder.title}`);
        console.log(`   الوصف: ${reminder.description || 'لا يوجد وصف'}`);
        console.log(`   الدواء: ${reminder.medicine_name} - ${reminder.dosage || ''}`);

        // يمكنك إضافة API call هنا لإرسال الإشعار الفعلي
        // مثال:
        // await fcmService.sendNotification({
        //     userId: reminder.user_id,
        //     title: reminder.title,
        //     body: reminder.description || `حان وقت أخذ ${reminder.medicine_name}`,
        //     data: { reminderId: reminder.id, medicineId: reminder.medicine_id }
        // });
    }

    /**
     * تحديث التذكير بعد المعالجة بناءً على التكرار
     */
    updateReminderAfterProcessing(reminder) {
        const frequency = reminder.frequency || 'once';

        if (frequency === 'once') {
            // تعطيل التذكير لمرة واحدة
            db.run(
                'UPDATE reminders SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                [reminder.id],
                (err) => {
                    if (err) {
                        console.error(`❌ خطأ في تحديث التذكير ${reminder.id}:`, err);
                    } else {
                        console.log(`✅ تم تعطيل التذكير ${reminder.id} (مرة واحدة)`);
                    }
                }
            );
        } else {
            // حساب الوقت القادم للتذكير المتكرر
            const nextTime = this.calculateNextReminderTime(reminder.scheduled_time, frequency);

            if (nextTime) {
                db.run(
                    'UPDATE reminders SET scheduled_time = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                    [nextTime.toISOString(), reminder.id],
                    (err) => {
                        if (err) {
                            console.error(`❌ خطأ في تحديث التذكير ${reminder.id}:`, err);
                        } else {
                            console.log(`✅ تم جدولة التذكير ${reminder.id} للمرة القادمة: ${nextTime.toISOString()}`);
                        }
                    }
                );
            } else {
                // إذا لم يتم حساب الوقت القادم، تعطيل التذكير
                db.run(
                    'UPDATE reminders SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
                    [reminder.id],
                    (err) => {
                        if (err) {
                            console.error(`❌ خطأ في تعطيل التذكير ${reminder.id}:`, err);
                        }
                    }
                );
            }
        }
    }

    /**
     * حساب الوقت القادم للتذكير بناءً على التكرار
     */
    calculateNextReminderTime(currentTime, frequency) {
        const current = new Date(currentTime);
        const next = new Date(current);

        switch (frequency.toLowerCase()) {
            case 'daily':
                next.setDate(next.getDate() + 1);
                break;
            case 'weekly':
                next.setDate(next.getDate() + 7);
                break;
            case 'monthly':
                next.setMonth(next.getMonth() + 1);
                break;
            case 'once':
            default:
                return null; // لا يوجد وقت قادم
        }

        return next;
    }

    /**
     * تحميل جميع التذكيرات النشطة عند البدء
     */
    loadActiveReminders() {
        const query = `
            SELECT COUNT(*) as count
            FROM reminders
            WHERE is_active = 1
            AND scheduled_time > datetime('now')
        `;

        db.get(query, [], (err, result) => {
            if (err) {
                console.error('❌ خطأ في تحميل التذكيرات النشطة:', err);
            } else {
                console.log(`📋 عدد التذكيرات النشطة: ${result.count}`);
            }
        });
    }
}

// إنشاء instance واحد من الـ scheduler
const reminderScheduler = new ReminderScheduler();

module.exports = reminderScheduler;

