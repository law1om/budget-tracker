package com.budgettracker.server.transaction;

import com.budgettracker.server.transaction.dto.TransactionRequest;
import com.budgettracker.server.transaction.dto.TransactionResponse;
import com.budgettracker.server.transaction.dto.TransactionStats;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;


@Service
public class TransactionService {
    
    private final TransactionRepository transactionRepository;
    
    public TransactionService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }
    
    
    @Transactional
    public TransactionResponse createTransaction(Long userId, TransactionRequest request) {
        System.out.println("=== Creating Transaction ===");
        System.out.println("User ID: " + userId);
        System.out.println("Type: " + request.getType());
        System.out.println("Title: " + request.getTitle());
        System.out.println("Amount: " + request.getAmount());
        System.out.println("Category ID: " + request.getCategoryId());
        
     
        String title = (request.getTitle() == null || request.getTitle().isBlank()) 
                ? "" 
                : request.getTitle();
        
        Transaction transaction = Transaction.builder()
                .userId(userId)
                .title(title)
                .amount(request.getAmount())
                .date(request.getDate())
                .categoryId(request.getCategoryId())
                .type(request.getType())
                .build();
        
        System.out.println("Transaction before save: " + transaction);
        transaction = transactionRepository.save(transaction);
        System.out.println("Transaction after save - ID: " + transaction.getId());
        System.out.println("=== Transaction Created Successfully ===");
        
        return TransactionResponse.fromEntity(transaction);
    }
    
    /**
     * Получить все транзакции пользователя
     */
    public List<TransactionResponse> getUserTransactions(Long userId) {
        return transactionRepository.findByUserIdOrderByDateDesc(userId)
                .stream()
                .map(TransactionResponse::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * Получить транзакции с пагинацией
     */
    public Page<TransactionResponse> getUserTransactionsPaginated(Long userId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return transactionRepository.findByUserIdOrderByDateDesc(userId, pageable)
                .map(TransactionResponse::fromEntity);
    }
    
    /**
     * Получить транзакцию по ID
     */
    public TransactionResponse getTransaction(Long userId, Long transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        if (!transaction.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied");
        }
        
        return TransactionResponse.fromEntity(transaction);
    }
    
    /**
     * Обновить транзакцию
     */
    @Transactional
    public TransactionResponse updateTransaction(Long userId, Long transactionId, TransactionRequest request) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        if (!transaction.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied");
        }
        
        // Use empty string if title is null or blank
        String title = (request.getTitle() == null || request.getTitle().isBlank()) 
                ? "" 
                : request.getTitle();
        
        transaction.setTitle(title);
        transaction.setAmount(request.getAmount());
        transaction.setDate(request.getDate());
        transaction.setCategoryId(request.getCategoryId());
        transaction.setType(request.getType());
        
        transaction = transactionRepository.save(transaction);
        
        return TransactionResponse.fromEntity(transaction);
    }
    
    /**
     * Удалить транзакцию
     */
    @Transactional
    public void deleteTransaction(Long userId, Long transactionId) {
        Transaction transaction = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new RuntimeException("Transaction not found"));
        
        if (!transaction.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied");
        }
        
        transactionRepository.delete(transaction);
    }
    
    /**
     * Получить статистику по транзакциям пользователя
     */
    public TransactionStats getUserStats(Long userId) {
        BigDecimal totalIncome = transactionRepository.sumIncomeByUserId(userId);
        BigDecimal totalExpense = transactionRepository.sumExpenseByUserId(userId);
        long count = transactionRepository.countByUserId(userId);
        
        BigDecimal balance = totalIncome.subtract(totalExpense);
        
        return TransactionStats.builder()
                .totalIncome(totalIncome)
                .totalExpense(totalExpense)
                .balance(balance)
                .transactionCount(count)
                .build();
    }
    
    /**
     * Получить транзакции по типу
     */
    public List<TransactionResponse> getUserTransactionsByType(Long userId, String type) {
        return transactionRepository.findByUserIdAndTypeOrderByDateDesc(userId, type)
                .stream()
                .map(TransactionResponse::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * Получить транзакции за период
     */
    public List<TransactionResponse> getUserTransactionsByDateRange(
            Long userId, LocalDateTime start, LocalDateTime end) {
        return transactionRepository.findByUserIdAndDateBetweenOrderByDateDesc(userId, start, end)
                .stream()
                .map(TransactionResponse::fromEntity)
                .collect(Collectors.toList());
    }
    
    /**
     * Удалить все транзакции пользователя
     */
    @Transactional
    public void deleteAllUserTransactions(Long userId) {
        transactionRepository.deleteByUserId(userId);
    }
}
