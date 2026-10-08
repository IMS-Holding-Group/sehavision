const db = require('../config/database');
const bcrypt = require('bcryptjs');
const { initializeDatabase, sampleMedicines } = require('./init-db');

// Create default admin user
const createAdminUser = () => {
  return new Promise((resolve, reject) => {
    const adminEmail = 'admin@sehavision.com';
    const adminPassword = 'admin123';
    const adminName = 'مدير النظام';

    // Check if admin already exists
    db.get('SELECT id FROM users WHERE email = ?', [adminEmail], (err, row) => {
      if (err) {
        return reject(err);
      }

      if (row) {
        console.log('Admin user already exists');
        // Update to ensure it's admin
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
              console.log('Admin user updated');
              resolve(row.id);
            }
          );
        });
      } else {
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
              console.log('Admin user created successfully');
              console.log('Email:', adminEmail);
              console.log('Password:', adminPassword);
              resolve(this.lastID);
            }
          );
        });
      }
    });
  });
};

// Create sample regular users
const createSampleUsers = (adminId) => {
  return new Promise((resolve, reject) => {
    const sampleUsers = [
      {
        email: 'user1@example.com',
        password: 'user123',
        name: 'أحمد محمد',
        phone: '0501234567',
        role: 'user'
      },
      {
        email: 'user2@example.com',
        password: 'user123',
        name: 'فاطمة علي',
        phone: '0507654321',
        role: 'user'
      },
      {
        email: 'user3@example.com',
        password: 'user123',
        name: 'خالد سعيد',
        phone: '0509876543',
        role: 'user'
      }
    ];

    let completed = 0;
    const errors = [];

    sampleUsers.forEach((userData) => {
      // Check if user exists
      db.get('SELECT id FROM users WHERE email = ?', [userData.email], (err, row) => {
        if (err) {
          errors.push(err);
          completed++;
          if (completed === sampleUsers.length) {
            if (errors.length > 0) {
              reject(errors[0]);
            } else {
              resolve();
            }
          }
          return;
        }

        if (row) {
          console.log(`User ${userData.email} already exists`);
          completed++;
          if (completed === sampleUsers.length) {
            if (errors.length > 0) {
              reject(errors[0]);
            } else {
              resolve();
            }
          }
          return;
        }

        // Create new user
        bcrypt.hash(userData.password, 10, (err, hash) => {
          if (err) {
            errors.push(err);
            completed++;
            if (completed === sampleUsers.length) {
              if (errors.length > 0) {
                reject(errors[0]);
              } else {
                resolve();
              }
            }
            return;
          }

          db.run(
            'INSERT INTO users (email, password_hash, name, phone, role) VALUES (?, ?, ?, ?, ?)',
            [userData.email, hash, userData.name, userData.phone, userData.role],
            function (err) {
              if (err) {
                errors.push(err);
              } else {
                console.log(`User ${userData.email} created`);
              }
              completed++;
              if (completed === sampleUsers.length) {
                if (errors.length > 0) {
                  reject(errors[0]);
                } else {
                  resolve();
                }
              }
            }
          );
        });
      });
    });
  });
};

// Add medicines with created_by tracking
const addMedicinesWithCreator = (adminId) => {
  return new Promise((resolve, reject) => {
    // First, check if medicines already exist
    db.get('SELECT COUNT(*) as count FROM medicines', [], (err, row) => {
      if (err) {
        return reject(err);
      }

      if (row.count > 0) {
        console.log('Medicines already exist, updating created_by...');
        // Update existing medicines to have admin as creator
        db.run(
          'UPDATE medicines SET created_by = ? WHERE created_by IS NULL',
          [adminId],
          (err) => {
            if (err) {
              console.error('Error updating medicines:', err);
            } else {
              console.log('Medicines updated with creator');
            }
            resolve();
          }
        );
      } else {
        // Add sample medicines
        console.log('Adding sample medicines...');
        const insertMedicine = (medicine) => {
          return new Promise((resolve, reject) => {
            const interactionsJson = JSON.stringify(medicine.interactions || []);
            const imagePathsJson = JSON.stringify(medicine.image_paths || []);

            db.run(
              `INSERT INTO medicines (name, brand, barcode, dosage, instructions, warnings, interactions, expiry_date, image_paths, created_by)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
              [
                medicine.name,
                medicine.brand,
                medicine.barcode,
                medicine.dosage,
                medicine.instructions,
                medicine.warnings,
                interactionsJson,
                medicine.expiry_date,
                imagePathsJson,
                adminId
              ],
              function (err) {
                if (err) {
                  reject(err);
                } else {
                  resolve(this.lastID);
                }
              }
            );
          });
        };

        Promise.all(sampleMedicines.map(insertMedicine))
          .then(() => {
            console.log('Sample medicines added successfully');
            resolve();
          })
          .catch(reject);
      }
    });
  });
};

// Main initialization function
const initializeAdmin = async () => {
  try {
    console.log('Initializing admin system...');
    
    // Wait a bit for database to be ready
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Create admin user
    const adminId = await createAdminUser();
    console.log('Admin ID:', adminId);

    // Create sample users
    await createSampleUsers(adminId);
    console.log('Sample users created');

    // Initialize database with sample data
    await initializeDatabase();
    console.log('Database initialized with sample data');

    // Add medicines with creator tracking
    await addMedicinesWithCreator(adminId);
    console.log('Medicines added with creator tracking');

    console.log('\n=== Initialization Complete ===');
    console.log('Admin Credentials:');
    console.log('Email: admin@sehavision.com');
    console.log('Password: admin123');
    console.log('\nSample User Credentials:');
    console.log('Email: user1@example.com');
    console.log('Password: user123');
    console.log('==============================\n');

    process.exit(0);
  } catch (error) {
    console.error('Error initializing admin:', error);
    process.exit(1);
  }
};

// Run if called directly
if (require.main === module) {
  initializeAdmin();
}

module.exports = { initializeAdmin, createAdminUser };

