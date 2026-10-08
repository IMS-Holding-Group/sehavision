const db = require('../config/database');

/**
 * Log an activity to the database
 * @param {Object} options - Log options
 * @param {number} options.user_id - User ID who performed the action
 * @param {string} options.action - Action type (create, update, delete, login, etc.)
 * @param {string} options.entity_type - Entity type (medicine, user, reminder, etc.)
 * @param {number} options.entity_id - Entity ID
 * @param {Object} options.details - Additional details (JSON object)
 * @param {string} options.ip_address - IP address
 * @param {string} options.user_agent - User agent
 */
const logActivity = (options) => {
  return new Promise((resolve, reject) => {
    const {
      user_id = null,
      action,
      entity_type,
      entity_id = null,
      details = null,
      ip_address = null,
      user_agent = null
    } = options;

    const detailsJson = details ? JSON.stringify(details) : null;

    db.run(
      `INSERT INTO activity_logs (user_id, action, entity_type, entity_id, details, ip_address, user_agent)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [user_id, action, entity_type, entity_id, detailsJson, ip_address, user_agent],
      function (err) {
        if (err) {
          console.error('Error logging activity:', err);
          reject(err);
        } else {
          resolve(this.lastID);
        }
      }
    );
  });
};

/**
 * Get activity logs with pagination
 * @param {Object} options - Query options
 * @param {number} options.page - Page number
 * @param {number} options.limit - Items per page
 * @param {number} options.user_id - Filter by user ID
 * @param {string} options.action - Filter by action
 * @param {string} options.entity_type - Filter by entity type
 */
const getActivityLogs = (options = {}) => {
  return new Promise((resolve, reject) => {
    const {
      page = 1,
      limit = 50,
      user_id = null,
      action = null,
      entity_type = null
    } = options;

    const offset = (page - 1) * limit;
    let query = `
      SELECT 
        al.*,
        u.name as user_name,
        u.email as user_email
      FROM activity_logs al
      LEFT JOIN users u ON al.user_id = u.id
      WHERE 1=1
    `;
    const params = [];

    if (user_id) {
      query += ' AND al.user_id = ?';
      params.push(user_id);
    }

    if (action) {
      query += ' AND al.action = ?';
      params.push(action);
    }

    if (entity_type) {
      query += ' AND al.entity_type = ?';
      params.push(entity_type);
    }

    query += ' ORDER BY al.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    db.all(query, params, (err, rows) => {
      if (err) {
        reject(err);
      } else {
        // Parse details JSON
        const logs = rows.map(row => ({
          ...row,
          details: row.details ? JSON.parse(row.details) : null
        }));
        resolve(logs);
      }
    });
  });
};

module.exports = {
  logActivity,
  getActivityLogs
};

