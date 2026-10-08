const db = require('../config/database');
const bcrypt = require('bcryptjs');

// Check and create admin user
const checkAndCreateAdmin = () => {
  return new Promise((resolve, reject) => {
    const adminEmail = 'admin@sehavision.com';
    const adminPassword = '';
    const adminName = 'مدير النظام';

    // Check if admin exists
    db.get('SELECT * FROM users WHERE email = ?', [adminEmail], (err, user) => {
      if (err) {
        return reject(err);
      }

      if (user) {
        console.log('✓ Admin user exists');
        console.log('Email:', user.email);
        console.log('Role:', user.role);
        console.log('Name:', user.name);
        
        // Verify password
        bcrypt.compare(adminPassword, user.password_hash, (err, isMatch) => {
          if (err) {
            console.error('Error verifying password:', err);
            return reject(err);
          }
          
          if (isMatch) {
            console.log('✓ Password is correct');
            resolve(user);
          } else {
            console.log('⚠ Password mismatch - updating password...');
            // Update password
            bcrypt.hash(adminPassword, 10, (err, hash) => {
              if (err) {
                return reject(err);
              }
              
              db.run(
                'UPDATE users SET password_hash = ?, role = ?, name = ? WHERE email = ?',
                [hash, 'admin', adminName, adminEmail],
                function (err) {
                  if (err) {
                    return reject(err);
                  }
                  console.log('✓ Password updated successfully');
                  resolve(user);
                }
              );
            });
          }
        });
      } else {
        console.log('✗ Admin user does not exist - creating...');
        // Create new admin user
        bcrypt.hash(adminPassword, 10, (err, hash) => {
          if (err) {
            return reject(err);
          }

          db.run(
            'INSERT INTO users (email, password_hash, name, role) VALUES (?, ?, ?, ?)',
            [adminEmail, hash, adminName, 'admin'],
            function (err) {
              if (err) {
                return reject(err);
              }
              console.log('✓ Admin user created successfully');
              console.log('Email:', adminEmail);
              console.log('Password:', adminPassword);
              console.log('Role: admin');
              resolve({ id: this.lastID, email: adminEmail, role: 'admin' });
            }
          );
        });
      }
    });
  });
};

// Run
if (require.main === module) {
  checkAndCreateAdmin()
    .then(() => {
      console.log('\n✅ Admin user is ready!');
      console.log('You can now login with:');
      console.log('Email: admin@sehavision.com');
      console.log('Password: \n');
      process.exit(0);
    })
    .catch((error) => {
      console.error('❌ Error:', error);
      process.exit(1);
    });
}

module.exports = { checkAndCreateAdmin };

