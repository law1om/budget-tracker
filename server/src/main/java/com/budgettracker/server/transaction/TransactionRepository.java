package com.budgettracker.server.transaction;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    
    /**
     * Найти все транзакции пользователя
     */
    List<Transaction> findByUserIdOrderByDateDesc(Long userId);
    
    /**
     * Найти транзакции пользователя с пагинацией
     */
    Page<Transaction> findByUserIdOrderByDateDesc(Long userId, Pageable pageable);
    
    /**
     * Найти транзакции пользователя по типу
     */
    List<Transaction> findByUserIdAndTypeOrderByDateDesc(Long userId, String type);
    
    /**
     * Найти транзакции пользователя за период
     */
    List<Transaction> findByUserIdAndDateBetweenOrderByDateDesc(
            Long userId, LocalDateTime start, LocalDateTime end);
    
    /**
     * Подсчитать общую сумму доходов пользователя
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.userId = :userId AND t.type = 'income'")
    BigDecimal sumIncomeByUserId(Long userId);
    
    /**
     * Подсчитать общую сумму расходов пользователя
     */
    @Query("SELECT COALESCE(SUM(t.amount), 0) FROM Transaction t WHERE t.userId = :userId AND t.type = 'expense'")
    BigDecimal sumExpenseByUserId(Long userId);
    
    /**
     * Удалить все транзакции пользователя
     */
    void deleteByUserId(Long userId);
    
    /**
     * Подсчитать количество транзакций пользователя
     */
    long countByUserId(Long userId);
}
