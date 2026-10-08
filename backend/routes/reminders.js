const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');

const router = express.Router();

// Get all reminders for user
router.get('/', authenticateToken, (req, res) => {
    const { limit = 50, offset = 0, active_only = false } = req.query;

    let query = `
    SELECT r.*, m.name as medicine_name, m.brand as medicine_brand, m.dosage
    FROM reminders r
    JOIN medicines m ON r.medicine_id = m.id
    WHERE r.user_id = ?
  `;

    const params = [req.user.id];

    if (active_only === 'true') {
        query += ' AND r.is_active = 1';
    }

    query += ' ORDER BY r.scheduled_time LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    db.all(query, params, (err, rows) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        res.json({ reminders: rows });
    });
});

// Get reminder by ID
router.get('/:id', authenticateToken, (req, res) => {
    const { id } = req.params;

    db.get(
        `SELECT r.*, m.name as medicine_name, m.brand as medicine_brand, m.dosage
     FROM reminders r
     JOIN medicines m ON r.medicine_id = m.id
     WHERE r.id = ? AND r.user_id = ?`,
        [id, req.user.id],
        (err, row) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!row) {
                return res.status(404).json({ error: 'Reminder not found' });
            }

            res.json({ reminder: row });
        }
    );
});

// Create new reminder
router.post('/', authenticateToken, validateRequest(schemas.reminder), (req, res) => {
    try {
        // Check if user is authenticated
        if (!req.user || !req.user.id) {
            console.error('❌ User not authenticated');
            return res.status(401).json({ error: 'User not authenticated' });
        }

        const { medicine_id, title, description, scheduled_time, frequency } = req.body;

        console.log('📝 Creating reminder - User ID:', req.user.id, 'Medicine ID:', medicine_id);
        console.log('📝 Reminder data:', { title, description, scheduled_time, frequency });

        // Check if medicine exists
        db.get('SELECT id FROM medicines WHERE id = ?', [medicine_id], (err, medicine) => {
            if (err) {
                console.error('❌ Database error checking medicine:', err);
                if (!res.headersSent) {
                    return res.status(500).json({ error: 'Database error', details: err.message });
                }
                return;
            }

            if (!medicine) {
                console.log('❌ Medicine not found:', medicine_id);
                if (!res.headersSent) {
                    return res.status(404).json({ error: 'Medicine not found' });
                }
                return;
            }

            console.log('✅ Medicine found');

            // Validate scheduled_time based on frequency
            let finalScheduledTime = scheduled_time;
            const scheduledDate = new Date(scheduled_time);
            const now = new Date();

            console.log('🕐 Time validation - Scheduled:', scheduledDate.toISOString(), 'Now:', now.toISOString(), 'Frequency:', frequency);

            // For "once" reminders, time must be in the future
            // For recurring reminders (daily, weekly, monthly), allow past times as they will repeat
            if (frequency === 'once' && scheduledDate <= now) {
                const timeDiff = Math.round((now - scheduledDate) / 1000 / 60); // difference in minutes
                console.log(`❌ Scheduled time is not in the future for one-time reminder (${timeDiff} minutes ago)`);
                if (!res.headersSent) {
                    return res.status(400).json({ 
                        error: 'Scheduled time must be in the future',
                        details: `The selected time was ${timeDiff} minutes ago. Please select a future time.`
                    });
                }
                return;
            }

            // For recurring reminders, if the time is in the past today, adjust to tomorrow
            if (frequency !== 'once' && scheduledDate <= now) {
                const scheduledTime = new Date(scheduledDate);
                const scheduledHours = scheduledTime.getHours();
                const scheduledMinutes = scheduledTime.getMinutes();
                
                // Get tomorrow's date with the same time
                const tomorrow = new Date(now);
                tomorrow.setDate(tomorrow.getDate() + 1);
                tomorrow.setHours(scheduledHours, scheduledMinutes, 0, 0);
                
                finalScheduledTime = tomorrow.toISOString();
                console.log('🔄 Adjusting recurring reminder time from past to future:', finalScheduledTime);
            }

            console.log('✅ Scheduled time validated');

            // Insert reminder
            db.run(
                'INSERT INTO reminders (user_id, medicine_id, title, description, scheduled_time, frequency) VALUES (?, ?, ?, ?, ?, ?)',
                [req.user.id, medicine_id, title, description || null, finalScheduledTime, frequency],
                function (err) {
                    if (err) {
                        console.error('❌ Failed to insert reminder:', err);
                        if (!res.headersSent) {
                            return res.status(500).json({ error: 'Failed to create reminder', details: err.message });
                        }
                        return;
                    }

                    console.log('✅ Reminder inserted, ID:', this.lastID);

                    // Get the created reminder with medicine details
                    db.get(
                        `SELECT r.*, m.name as medicine_name, m.brand as medicine_brand, m.dosage
           FROM reminders r
           JOIN medicines m ON r.medicine_id = m.id
           WHERE r.id = ?`,
                        [this.lastID],
                        (err, reminder) => {
                            if (err) {
                                console.error('❌ Failed to fetch created reminder:', err);
                                if (!res.headersSent) {
                                    return res.status(500).json({ error: 'Database error', details: err.message });
                                }
                                return;
                            }

                            if (!reminder) {
                                console.error('❌ Reminder not found after insertion');
                                if (!res.headersSent) {
                                    return res.status(500).json({ error: 'Reminder created but not found' });
                                }
                                return;
                            }

                            console.log('✅ Reminder created successfully');
                            console.log('📤 Sending response...');
                            if (!res.headersSent) {
                                res.status(201).json({
                                    message: 'Reminder created successfully',
                                    reminder
                                });
                                console.log('✅ Response sent successfully');
                            } else {
                                console.warn('⚠️ Response already sent, skipping');
                            }
                        }
                    );
                }
            );
        });
    } catch (error) {
        console.error('❌ Unexpected error in create reminder:', error);
        if (!res.headersSent) {
            res.status(500).json({ error: 'Internal server error', details: error.message });
        }
    }
});

// Update reminder
router.put('/:id', authenticateToken, validateRequest(schemas.reminder), (req, res) => {
    const { id } = req.params;
    const { medicine_id, title, description, scheduled_time, frequency } = req.body;

    // Check if reminder exists and belongs to user
    db.get('SELECT id FROM reminders WHERE id = ? AND user_id = ?', [id, req.user.id], (err, reminder) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!reminder) {
            return res.status(404).json({ error: 'Reminder not found' });
        }

        // Check if medicine exists
        db.get('SELECT id FROM medicines WHERE id = ?', [medicine_id], (err, medicine) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!medicine) {
                return res.status(404).json({ error: 'Medicine not found' });
            }

            // Update reminder
            db.run(
                `UPDATE reminders SET 
         medicine_id = ?, title = ?, description = ?, scheduled_time = ?, 
         frequency = ?, updated_at = CURRENT_TIMESTAMP
         WHERE id = ? AND user_id = ?`,
                [medicine_id, title, description || null, scheduled_time, frequency, id, req.user.id],
                function (err) {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to update reminder' });
                    }

                    if (this.changes === 0) {
                        return res.status(404).json({ error: 'Reminder not found' });
                    }

                    // Get updated reminder
                    db.get(
                        `SELECT r.*, m.name as medicine_name, m.brand as medicine_brand, m.dosage
             FROM reminders r
             JOIN medicines m ON r.medicine_id = m.id
             WHERE r.id = ?`,
                        [id],
                        (err, updatedReminder) => {
                            if (err) {
                                return res.status(500).json({ error: 'Database error' });
                            }

                            res.json({
                                message: 'Reminder updated successfully',
                                reminder: updatedReminder
                            });
                        }
                    );
                }
            );
        });
    });
});

// Delete reminder
router.delete('/:id', authenticateToken, (req, res) => {
    const { id } = req.params;

    db.run('DELETE FROM reminders WHERE id = ? AND user_id = ?', [id, req.user.id], function (err) {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (this.changes === 0) {
            return res.status(404).json({ error: 'Reminder not found' });
        }

        res.json({ message: 'Reminder deleted successfully' });
    });
});

// Toggle reminder active status
router.patch('/:id/toggle', authenticateToken, (req, res) => {
    const { id } = req.params;

    db.get('SELECT is_active FROM reminders WHERE id = ? AND user_id = ?', [id, req.user.id], (err, reminder) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!reminder) {
            return res.status(404).json({ error: 'Reminder not found' });
        }

        const newStatus = reminder.is_active ? 0 : 1;

        db.run(
            'UPDATE reminders SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?',
            [newStatus, id, req.user.id],
            function (err) {
                if (err) {
                    return res.status(500).json({ error: 'Failed to update reminder' });
                }

                res.json({
                    message: `Reminder ${newStatus ? 'activated' : 'deactivated'} successfully`,
                    is_active: newStatus === 1
                });
            }
        );
    });
});

// Get upcoming reminders (next 24 hours)
router.get('/upcoming/24h', authenticateToken, (req, res) => {
    const now = new Date();
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    db.all(
        `SELECT r.*, m.name as medicine_name, m.brand as medicine_brand, m.dosage
     FROM reminders r
     JOIN medicines m ON r.medicine_id = m.id
     WHERE r.user_id = ? AND r.is_active = 1 
     AND r.scheduled_time BETWEEN ? AND ?
     ORDER BY r.scheduled_time`,
        [req.user.id, now.toISOString(), tomorrow.toISOString()],
        (err, rows) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            res.json({
                upcoming_reminders: rows,
                count: rows.length,
                time_range: '24 hours'
            });
        }
    );
});

module.exports = router;
