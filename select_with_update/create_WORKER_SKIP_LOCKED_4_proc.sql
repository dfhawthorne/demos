-- -----------------------------------------------------------------------------
-- Create worker procedure to process the unmodified entries in the queue table.
--
-- ===> Version to skip locked rows but still getting 4 row in the inner query<===
--
-- -----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE "DEER"."WORKER_SKIP_LOCKED_4"(
    p_client_id     IN VARCHAR2,
    p_delay         IN NUMBER
    )
IS
    -- Identify the terminal from which the worker is running
    l_terminal_id
        VARCHAR2(64)
        := USERENV('TERMINAL');

    -- Get the next available piece of work
    CURSOR csr_next_avail IS
      SELECT --+ FIRST_ROWS(1)
          *
        FROM
          "DEER"."NRIV"
        WHERE
          rowid IN (
            SELECT
                rowid
              FROM
                "DEER"."NRIV"
              WHERE
                  "CLIENT" = p_client_id
                AND
                  "IS_UPDATED" = 'N'
              FETCH FIRST 4 ROW ONLY
          )
      FOR UPDATE SKIP LOCKED
    ;

    -- Current row
    l_curr_row
        csr_next_avail%ROWTYPE;

    -- Run counters
    l_start_time
        TIMESTAMP
        := SYSTIMESTAMP;
    l_end_time
        TIMESTAMP;
    l_num_processed
        NUMBER
        := 0;
        
BEGIN
    LOOP
        OPEN csr_next_avail;
        FETCH csr_next_avail INTO l_curr_row;
        EXIT WHEN csr_next_avail%NOTFOUND;
        l_curr_row."IS_UPDATED"   := 'Y';
        l_curr_row."UPDATED_FROM" := l_terminal_id;
        l_curr_row."UPDATED_TIME" := SYSTIMESTAMP;
        UPDATE "DEER"."NRIV"
            SET ROW = l_curr_row
            WHERE CURRENT OF csr_next_avail;
        l_num_processed := l_num_processed + 1;
        dbms_lock.sleep( p_delay );
        CLOSE csr_next_avail;
        COMMIT;
    END LOOP;
    -- All rows have been processed - print statistics
    l_end_time := SYSTIMESTAMP;
    CLOSE csr_next_avail;
    ROLLBACK;
    dbms_output.put_line(
        'Execution on ' || l_terminal_id || ' started at ' ||
        to_char(l_start_time)
        );
    dbms_output.put_line(
        'Execution ended at ' ||
        to_char(l_end_time)
        );
    dbms_output.put_line(
        to_char(l_num_processed) ||
        ' rows processed.'
        );
    dbms_output.put_line(
        'Execution took ' ||
        to_char(l_end_time - l_start_time)
        );
END;
/
