#Author: Vitaly Spirin


DROP PROCEDURE IF EXISTS usp_update_schema;

DELIMITER $

CREATE PROCEDURE usp_update_schema()
BEGIN
	CREATE TABLE IF NOT EXISTS version
	(
		version_id	DATETIME PRIMARY KEY,
		version_comment VARCHAR(255) NOT NULL,
		version_timestamp	TIMESTAMP NOT NULL,
		version_sql TEXT NULL DEFAULT NULL COMMENT 'applied SQL statement',
		version_developer VARCHAR(255) NULL COMMENT 'Name of developer who added SQL statement'
	);
	
	DROP TABLE IF EXISTS versionupdate;
	CREATE TEMPORARY TABLE versionupdate (versionupdate_status VARCHAR(255));



	# ---------------------------------------------------------------------------

	SET @version_id = "2014-06-04 11:00:00";
	SET @version_comment = "Creating tables 'test1' and 'test1'";
	SET @version_developer = 'Vitaly Spirin';

	SET @sqlStr1 = "
		CREATE TABLE test1
    (
      test1_id INTEGER AUTO_INCREMENT PRIMARY KEY
    );
	";

	SET @sqlStr2 = "
		CREATE TABLE test2
    (
      test2_id INTEGER AUTO_INCREMENT PRIMARY KEY
    );
	";

	SET @result = (SELECT version_id FROM version WHERE version_id = @version_id);

	IF (@result IS NULL)
	THEN 
		START TRANSACTION;
		PREPARE stmt1 FROM @sqlStr1;
		EXECUTE stmt1;

    PREPARE stmt2 FROM @sqlStr2;
		EXECUTE stmt2;
    
		SET @sqlStr = CONCAT(@sqlStr1, @sqlStr2);
		
		INSERT INTO version(version_id, version_comment, version_timestamp, version_sql, version_developer) 
		VALUES(@version_id, @version_comment, CURRENT_TIMESTAMP(), @sqlStr, @version_developer);
		
		INSERT INTO versionupdate 
		VALUES( 
			CONCAT('Updated to version = ', @version_id, ' (', @version_comment, '). Author: ', @version_developer) 
		);
		COMMIT;
	END IF;

	# ---------------------------------------------------------------------------


	SELECT * FROM versionupdate;
END$


DELIMITER ;

call usp_update_schema();
