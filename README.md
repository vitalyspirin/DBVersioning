DBVersioning
============

DDL and DML updates are done through stored procedure which also adds a record into 'version' table with description, date, SQL string and developer's name.
Update will be applied only if it doesn't have corresponding record in 'version' table (i.e. it hasn't been applied before).
In this case it's easy to apply changes to different staging servers without manual tracking of which changes were already applied to which server.

Each update will have a section in stored procedure similar to this:

```SQL
# ---------------------------------------------------------------------------
	SET @version_id = '2014-06-04 11:00:00';
	SET @version_comment = 'Creating table "test1"';
	SET @version_developer = 'Vitaly Spirin';

	SET @sqlStr1 = '
		CREATE TABLE test1
		(
			test1_id INTEGER AUTO_INCREMENT PRIMARY KEY
		);
	';

	SET @result = (SELECT version_id FROM version WHERE version_id = @version_id);

	IF (@result IS NULL)
	THEN 
		START TRANSACTION;
		PREPARE stmt1 FROM @sqlStr1;
		EXECUTE stmt1;

		INSERT INTO version(version_id, version_comment, version_timestamp, version_sql, version_developer) 
		VALUES(@version_id, @version_comment, CURRENT_TIMESTAMP(), @sqlStr1, @version_developer);
		
		INSERT INTO versionupdate 
		VALUES( 
			CONCAT('Updated to version = ', @version_id, ' (', @version_comment, '). Author: ', @version_developer) 
		);
		COMMIT;
	END IF;
# ---------------------------------------------------------------------------
```

If you realized that you want to modify update that had been already applied then instead of changing existing section in stored procedure you need to add a new one with 
further change!

After stored procedure was run list of applied updates (if any) will be shown:

	Updated to version = 2014-06-04 11:00:00 (Creating table "test1"). Author: Vitaly Spirin

'version' table will have corresponding data:

![screenshot1.png](/docs/screenshot1.png "'version' table screenshot")
