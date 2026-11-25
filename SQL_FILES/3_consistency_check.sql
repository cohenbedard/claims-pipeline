SELECT 
    (SELECT COUNT(*) FROM policies_clean) AS policies_clean_count,
    (SELECT COUNT(*) FROM claims_clean)   AS claims_clean_count;