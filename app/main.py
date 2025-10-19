from flask import Flask, jsonify
import psycopg2
import os
import time
from datetime import datetime

app = Flask(__name__)

# Database configuration from environment variables
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'production-db-instance.c3g4a2yg2m9y.ap-southeast-1.rds.amazonaws.com'),
    'port': os.getenv('DB_PORT', '3306'),
    'database': os.getenv('DB_NAME', 'mydatabase'),
    'user': os.getenv('DB_USER', 'admin'),
    'password': os.getenv('DB_PASSWORD', 'hatta123')
}

def get_db_connection():
    """Create database connection with retry logic"""
    max_retries = 3
    retry_delay = 2
    
    for attempt in range(max_retries):
        try:
            conn = psycopg2.connect(**DB_CONFIG)
            return conn
        except psycopg2.OperationalError as e:
            if attempt < max_retries - 1:
                time.sleep(retry_delay)
            else:
                raise e

@app.route('/')
def home():
    """Home endpoint"""
    return jsonify({
        'message': 'Mock Application Running',
        'timestamp': datetime.now().isoformat(),
        'endpoints': {
            '/': 'Home',
            '/health': 'Health check',
            '/db-check': 'Database connectivity check',
            '/db-info': 'Database information'
        }
    })

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes probes"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    }), 200

@app.route('/db-check')
def db_check():
    """Check database connectivity"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT version();')
        version = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        
        return jsonify({
            'status': 'success',
            'message': 'Database connection successful',
            'database_version': version,
            'timestamp': datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': 'Database connection failed',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/db-info')
def db_info():
    """Get database information"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get database name
        cursor.execute('SELECT current_database();')
        db_name = cursor.fetchone()[0]
        
        # Get current timestamp from database
        cursor.execute('SELECT NOW();')
        db_time = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'status': 'success',
            'database_name': db_name,
            'database_time': str(db_time),
            'connection_host': DB_CONFIG['host'],
            'timestamp': datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': 'Failed to fetch database info',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    # Run on all interfaces for container accessibility
    app.run(host='0.0.0.0', port=8080, debug=False)