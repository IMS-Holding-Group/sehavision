const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
const fs = require('fs');

// Import routes
const authRoutes = require('./routes/auth');
const medicineRoutes = require('./routes/medicines');
const scanRoutes = require('./routes/scan');
const interactionRoutes = require('./routes/interactions');
const reminderRoutes = require('./routes/reminders');
const adminRoutes = require('./routes/admin');
const reminderScheduler = require('./services/reminderScheduler');

const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint - MUST be first
app.get('/api/health', (req, res) => {
    console.log('✓ Health check endpoint called:', req.method, req.path);
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'SehaVision API',
        version: '1.0.0',
        health: '/api/health'
    });
});

// CORS middleware
app.use(cors({
    origin: '*',
    credentials: true
}));

// Security middleware - TEMPORARILY DISABLED FOR DEBUGGING
// app.use(helmet({
//     contentSecurityPolicy: false
// }));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100
});
app.use((req, res, next) => {
    if (req.path === '/api/health') {
        return next();
    }
    limiter(req, res, next);
});

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

// Static files - AFTER routes to avoid conflicts
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/assets', express.static(path.join(__dirname, 'assets')));

// Create necessary directories
const uploadsDir = path.join(__dirname, 'uploads');
const assetsDir = path.join(__dirname, 'assets');
const samplesDir = path.join(__dirname, 'assets', 'samples');

if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}
if (!fs.existsSync(assetsDir)) {
    fs.mkdirSync(assetsDir, { recursive: true });
}
if (!fs.existsSync(samplesDir)) {
    fs.mkdirSync(samplesDir, { recursive: true });
}

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/medicines', medicineRoutes);
app.use('/api/scan', scanRoutes);
app.use('/api/interactions', interactionRoutes);
app.use('/api/reminders', reminderRoutes);
app.use('/api/admin', adminRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        error: err.message || 'Internal Server Error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
});

// 404 handler - must be last
app.use((req, res) => {
    console.log(`404 - Route not found: ${req.method} ${req.path}`);
    res.status(404).json({ 
        error: `The requested resource ${req.path} was not found on this server.`,
        availableRoutes: ['/api/health', '/api/auth', '/api/medicines', '/api/scan', '/api/interactions', '/api/reminders', '/api/admin']
    });
});

// Start server
if (process.env.NODE_ENV !== 'test') {
    // Listen on 0.0.0.0 to allow connections from Android emulator (10.0.2.2)
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`SehaVision Backend running on port ${PORT}`);
        console.log(`Health check: http://localhost:${PORT}/api/health`);
        console.log(`Test root: http://localhost:${PORT}/`);
        console.log(`Emulator access: http://10.0.2.2:${PORT}/api`);
        
        // بدء خدمة جدولة التذكيرات
        reminderScheduler.start();
    });
}

module.exports = app;
