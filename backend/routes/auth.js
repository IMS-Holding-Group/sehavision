const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/database');
const { generateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');
const { logActivity } = require('../utils/logger');

const router = express.Router();

// Register
router.post('/register', validateRequest(schemas.register), (req, res) => {
    const { email, password, name, phone } = req.body;

    // Check if user already exists
    db.get('SELECT id FROM users WHERE email = ?', [email], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (row) {
            return res.status(400).json({ error: 'User already exists' });
        }

        // Hash password
        bcrypt.hash(password, 10, (err, hash) => {
            if (err) {
                return res.status(500).json({ error: 'Password hashing error' });
            }

            // Insert user
            db.run(
                'INSERT INTO users (email, password_hash, name, phone) VALUES (?, ?, ?, ?)',
                [email, hash, name, phone || null],
                function (err) {
                    if (err) {
                        console.error('Database error creating user:', err);
                        return res.status(500).json({ error: 'Failed to create user' });
                    }

                    const token = generateToken({ id: this.lastID, email });

                    // Get the created user with role
                    db.get('SELECT id, email, name, phone, role FROM users WHERE id = ?', [this.lastID], (err, user) => {
                        if (err) {
                            return res.status(500).json({ error: 'Failed to fetch user' });
                        }

                        res.status(201).json({
                            success: true,
                            message: 'User created successfully',
                            token,
                            user: {
                                id: user.id,
                                email: user.email,
                                name: user.name,
                                phone: user.phone,
                                role: user.role || 'user'
                            }
                        });
                    });
                }
            );
        });
    });
});

// Login
router.post('/login', validateRequest(schemas.login), (req, res) => {
    const { email, password } = req.body;
    
    console.log('🔐 Login attempt:', { email, passwordLength: password?.length });

    db.get('SELECT * FROM users WHERE email = ?', [email], (err, user) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!user) {
            console.log('❌ User not found:', email);
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        console.log('✓ User found:', { id: user.id, email: user.email, role: user.role });
        bcrypt.compare(password, user.password_hash, (err, isMatch) => {
            if (err) {
                return res.status(500).json({ error: 'Password comparison error' });
            }

            if (!isMatch) {
                console.log('❌ Password mismatch for user:', email);
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            console.log('✅ Login successful for user:', email);

            const token = generateToken({ id: user.id, email: user.email });

            // Log login activity
            logActivity({
                user_id: user.id,
                action: 'login',
                entity_type: 'user',
                entity_id: user.id,
                details: { email: user.email },
                ip_address: req.ip || req.connection.remoteAddress,
                user_agent: req.get('user-agent')
            }).catch(err => console.error('Failed to log activity:', err));

            res.json({
                success: true,
                message: 'Login successful',
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    phone: user.phone,
                    role: user.role || 'user'
                }
            });
        });
    });
});

// Get current user profile
router.get('/profile', require('../middleware/auth').authenticateToken, (req, res) => {
    res.json({
        user: req.user
    });
});

// TEMPORARY: Create admin user endpoint (for development only)
router.post('/create-admin', (req, res) => {
    const adminEmail = 'admin@sehavision.com';
    const adminPassword = 'admin123';
    const adminName = 'مدير النظام';

    // Check if admin already exists
    db.get('SELECT * FROM users WHERE email = ?', [adminEmail], (err, existingUser) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Database error' });
        }

        if (existingUser) {
            // Update password to ensure it's correct
            bcrypt.hash(adminPassword, 10, (err, hash) => {
                if (err) {
                    return res.status(500).json({ error: 'Password hashing error' });
                }

                db.run(
                    'UPDATE users SET password_hash = ?, role = ?, name = ? WHERE email = ?',
                    [hash, 'admin', adminName, adminEmail],
                    function (err) {
                        if (err) {
                            console.error('Update error:', err);
                            return res.status(500).json({ error: 'Failed to update admin' });
                        }

                        console.log('✅ Admin user updated');
                        return res.json({
                            success: true,
                            message: 'Admin user updated successfully',
                            email: adminEmail,
                            password: adminPassword
                        });
                    }
                );
            });
        } else {
            // Create new admin user
            bcrypt.hash(adminPassword, 10, (err, hash) => {
                if (err) {
                    return res.status(500).json({ error: 'Password hashing error' });
                }

                db.run(
                    'INSERT INTO users (email, password_hash, name, role) VALUES (?, ?, ?, ?)',
                    [adminEmail, hash, adminName, 'admin'],
                    function (err) {
                        if (err) {
                            console.error('Insert error:', err);
                            return res.status(500).json({ error: 'Failed to create admin' });
                        }

                        console.log('✅ Admin user created');
                        return res.json({
                            success: true,
                            message: 'Admin user created successfully',
                            email: adminEmail,
                            password: adminPassword
                        });
                    }
                );
            });
        }
    });
});

module.exports = router;
