/*
  Snowflake Drone EXIF Extraction Demo Setup
  
  This script sets up the database, schema, and stage for processing drone imagery
  with EXIF metadata extraction capabilities.
  
  Prerequisites:
  - Run with SYSADMIN role
  - Ensure the DroneImages folder contains drone images to be uploaded
*/

-- Use SYSADMIN role as specified in requirements
USE ROLE SYSADMIN;

-- Create the DRONE_DB database
CREATE DATABASE IF NOT EXISTS DRONE_DB
  COMMENT = 'Database for drone imagery and EXIF metadata processing demo';

-- Use the database
USE DATABASE DRONE_DB;

-- Create a schema for our drone operations
CREATE SCHEMA IF NOT EXISTS DRONE_OPERATIONS
  COMMENT = 'Schema for drone image processing and metadata extraction';

USE SCHEMA DRONE_OPERATIONS;

-- Create an internal stage for storing drone images
CREATE STAGE IF NOT EXISTS DRONE_IMAGES_STAGE
DIRECTORY = ( ENABLE = true ) 
	ENCRYPTION = ( TYPE = 'SNOWFLAKE_SSE' )
  COMMENT = 'Internal stage for storing drone images with EXIF metadata';

--upload some images using teh UI or SnowCLI - can use this site: https://dronemapper.com/sample_data/
-- Create a table to store extracted EXIF metadata
CREATE TABLE IF NOT EXISTS DRONE_METADATA (
    file_name STRING,
    file_path STRING,
    file_size NUMBER,
    upload_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    -- Camera Information
    camera_make STRING,
    camera_model STRING,
    
    -- GPS Coordinates
    gps_latitude FLOAT,
    gps_longitude FLOAT,
    gps_altitude FLOAT,
    gps_altitude_ref STRING,
    
    -- Image Properties
    image_width NUMBER,
    image_height NUMBER,
    orientation NUMBER,
    
    -- Camera Settings
    focal_length FLOAT,
    aperture_value FLOAT,
    iso_speed NUMBER,
    exposure_time STRING,
    white_balance STRING,
    
    -- Date/Time Information
    datetime_original TIMESTAMP_NTZ,
    datetime_digitized TIMESTAMP_NTZ,
    
    -- DJI Specific Information
    drone_model STRING,
    flight_altitude FLOAT,
    gimbal_roll FLOAT,
    gimbal_yaw FLOAT,
    gimbal_pitch FLOAT,
    
    -- Raw EXIF data as JSON for additional fields
    raw_exif_data VARIANT
);

-- Grant necessary privileges
GRANT USAGE ON DATABASE DRONE_DB TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA DRONE_OPERATIONS TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON STAGE DRONE_IMAGES_STAGE TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON TABLE DRONE_METADATA TO ROLE SYSADMIN;

-- Show created objects
SHOW DATABASES LIKE 'DRONE_DB';
SHOW SCHEMAS IN DATABASE DRONE_DB;
SHOW STAGES IN SCHEMA DRONE_OPERATIONS;
SHOW TABLES IN SCHEMA DRONE_OPERATIONS;

-- Instructions for uploading files to the stage
SELECT 'Setup complete! Now upload your drone images to the stage using SnowCLI:' AS INSTRUCTION
UNION ALL
SELECT 'snow stage copy "DroneImages/*.JPG" @DRONE_IMAGES_STAGE' AS INSTRUCTION
UNION ALL  
SELECT 'Then run the Snowflake notebook to process the images and extract EXIF data.' AS INSTRUCTION;
