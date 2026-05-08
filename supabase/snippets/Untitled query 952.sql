SELECT
    tc.constraint_name,
    kcu.column_name AS from_column,
    ccu.column_name AS to_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_name = 'goals' 
  AND tc.constraint_type = 'FOREIGN KEY'
  AND tc.constraint_name = 'goals_parent_id_fkey';
