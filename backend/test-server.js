const express = require('express');
const app = express();
const PORT = 3000;

// Health check endpoint - VERY FIRST
app.get('/api/health', (req, res) => {
    console.log('✓ Health check called!');
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    console.log('✓ Root called!');
    res.json({
        message: 'SehaVision API',
        version: '1.0.0',
        health: '/api/health'
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`Test server running on port ${PORT}`);
    console.log(`Health: http://localhost:${PORT}/api/health`);
    console.log(`Root: http://localhost:${PORT}/`);
});

