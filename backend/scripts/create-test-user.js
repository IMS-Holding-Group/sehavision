const db = require('../config/database');
const bcrypt = require('bcryptjs');

// Create test user
const createTestUser = () => {
    return new Promise((resolve, reject) => {
        const email = 'email@gmail.com';
        const password = 'password123';
        const name = 'Test User';
        
        // Check if user already exists
        db.get('SELECT id FROM users WHERE email = ?', [email], (err, row) => {
            if (err) {
                return reject(err);
            }
            
            if (row) {
                console.log('User already exists. Updating password...');
                // Update password
                bcrypt.hash(password, 10, (err, hash) => {
                    if (err) {
                        return reject(err);
                    }
                    
                    db.run('UPDATE users SET password_hash = ? WHERE email = ?', [hash, email], (err) => {
                        if (err) {
                            return reject(err);
                        }
                        console.log('✓ Password updated successfully');
                        console.log(`Email: ${email}`);
                        console.log(`Password: ${password}`);
                        resolve();
                    });
                });
            } else {
                // Create new user
                bcrypt.hash(password, 10, (err, hash) => {
                    if (err) {
                        return reject(err);
                    }
                    
                    db.run(
                        'INSERT INTO users (email, password_hash, name) VALUES (?, ?, ?)',
                        [email, hash, name],
                        function (err) {
                            if (err) {
                                return reject(err);
                            }
                            console.log('✓ Test user created successfully');
                            console.log(`Email: ${email}`);
                            console.log(`Password: ${password}`);
                            resolve();
                        }
                    );
                });
            }
        });
    });
};

// Run
if (require.main === module) {
    createTestUser()
        .then(() => {
            console.log('Done!');
            process.exit(0);
        })
        .catch((err) => {
            console.error('Error:', err);
            process.exit(1);
        });
}

module.exports = { createTestUser };

