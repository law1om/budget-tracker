package com.budgettracker.server.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * Utility to check and fix database constraints
 * This will run on application startup
 */
@Component
public class DatabaseConstraintChecker implements CommandLineRunner {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Override
    public void run(String... args) throws Exception {
        System.out.println("=== Checking Database Constraints ===");
        
        // Check for CHECK constraints on transactions table
        String query = """
            SELECT
                con.conname AS constraint_name,
                pg_get_constraintdef(con.oid) AS constraint_definition
            FROM
                pg_constraint con
                INNER JOIN pg_class rel ON rel.oid = con.conrelid
                INNER JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
            WHERE
                rel.relname = 'transactions'
                AND nsp.nspname = 'public'
                AND con.contype = 'c'
            """;
        
        try {
            List<Map<String, Object>> constraints = jdbcTemplate.queryForList(query);
            
            if (constraints.isEmpty()) {
                System.out.println("No CHECK constraints found on transactions table");
            } else {
                System.out.println("Found CHECK constraints:");
                for (Map<String, Object> constraint : constraints) {
                    String name = (String) constraint.get("constraint_name");
                    String definition = (String) constraint.get("constraint_definition");
                    System.out.println("  - " + name + ": " + definition);
                    
                    // Check if this constraint is blocking income transactions
                    if (definition != null && definition.toLowerCase().contains("type") && 
                        definition.toLowerCase().contains("expense") && 
                        !definition.toLowerCase().contains("income")) {
                        System.out.println("    ⚠️  WARNING: This constraint may be blocking income transactions!");
                        System.out.println("    Attempting to fix...");
                        
                        try {
                            // Drop the old constraint
                            jdbcTemplate.execute("ALTER TABLE transactions DROP CONSTRAINT IF EXISTS " + name);
                            System.out.println("    ✓ Dropped constraint: " + name);
                            
                            // Add new constraint that allows both income and expense
                            jdbcTemplate.execute(
                                "ALTER TABLE transactions ADD CONSTRAINT " + name + 
                                " CHECK (type IN ('income', 'expense'))"
                            );
                            System.out.println("    ✓ Created new constraint allowing both 'income' and 'expense'");
                        } catch (Exception e) {
                            System.out.println("    ✗ Failed to fix constraint: " + e.getMessage());
                        }
                    }
                }
            }
            
            // Check current transaction types
            String typeQuery = "SELECT type, COUNT(*) as count FROM transactions GROUP BY type";
            List<Map<String, Object>> typeCounts = jdbcTemplate.queryForList(typeQuery);
            System.out.println("\nCurrent transaction types in database:");
            for (Map<String, Object> row : typeCounts) {
                System.out.println("  - " + row.get("type") + ": " + row.get("count"));
            }
            
        } catch (Exception e) {
            System.out.println("Error checking constraints: " + e.getMessage());
        }
        
        System.out.println("=== Database Constraint Check Complete ===\n");
    }
}
