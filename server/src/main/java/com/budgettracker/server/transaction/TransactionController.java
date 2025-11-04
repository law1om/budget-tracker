package com.budgettracker.server.transaction;

import com.budgettracker.server.transaction.dto.TransactionRequest;
import com.budgettracker.server.transaction.dto.TransactionResponse;
import com.budgettracker.server.transaction.dto.TransactionStats;
import com.budgettracker.server.user.User;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Контроллер для работы с транзакциями
 */
@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    
    private final TransactionService transactionService;
    
    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }
    
    /**
     * Создать новую транзакцию
     */
    @PostMapping
    public ResponseEntity<TransactionResponse> createTransaction(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody TransactionRequest request) {
        
        TransactionResponse response = transactionService.createTransaction(user.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    /**
     * Получить все транзакции пользователя
     */
    @GetMapping
    public ResponseEntity<List<TransactionResponse>> getTransactions(
            @AuthenticationPrincipal User user) {
        
        List<TransactionResponse> transactions = transactionService.getUserTransactions(user.getId());
        return ResponseEntity.ok(transactions);
    }
    
    /**
     * Получить транзакции с пагинацией
     */
    @GetMapping("/paginated")
    public ResponseEntity<Page<TransactionResponse>> getTransactionsPaginated(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        
        Page<TransactionResponse> transactions = transactionService.getUserTransactionsPaginated(
                user.getId(), page, size);
        return ResponseEntity.ok(transactions);
    }
    
    /**
     * Получить транзакцию по ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<TransactionResponse> getTransaction(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        
        TransactionResponse transaction = transactionService.getTransaction(user.getId(), id);
        return ResponseEntity.ok(transaction);
    }
    
    /**
     * Обновить транзакцию
     */
    @PutMapping("/{id}")
    public ResponseEntity<TransactionResponse> updateTransaction(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody TransactionRequest request) {
        
        TransactionResponse response = transactionService.updateTransaction(user.getId(), id, request);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Удалить транзакцию
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteTransaction(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        
        transactionService.deleteTransaction(user.getId(), id);
        return ResponseEntity.ok(Map.of("message", "Transaction deleted successfully"));
    }
    
    /**
     * Получить статистику по транзакциям
     */
    @GetMapping("/stats")
    public ResponseEntity<TransactionStats> getStats(@AuthenticationPrincipal User user) {
        TransactionStats stats = transactionService.getUserStats(user.getId());
        return ResponseEntity.ok(stats);
    }
    
    /**
     * Получить транзакции по типу
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<TransactionResponse>> getTransactionsByType(
            @AuthenticationPrincipal User user,
            @PathVariable String type) {
        
        List<TransactionResponse> transactions = transactionService.getUserTransactionsByType(
                user.getId(), type);
        return ResponseEntity.ok(transactions);
    }
    
    /**
     * Получить транзакции за период
     */
    @GetMapping("/range")
    public ResponseEntity<List<TransactionResponse>> getTransactionsByDateRange(
            @AuthenticationPrincipal User user,
            @RequestParam String start,
            @RequestParam String end) {
        
        LocalDateTime startDate = LocalDateTime.parse(start);
        LocalDateTime endDate = LocalDateTime.parse(end);
        
        List<TransactionResponse> transactions = transactionService.getUserTransactionsByDateRange(
                user.getId(), startDate, endDate);
        return ResponseEntity.ok(transactions);
    }
    
    /**
     * Удалить все транзакции пользователя
     */
    @DeleteMapping("/all")
    public ResponseEntity<Map<String, String>> deleteAllTransactions(
            @AuthenticationPrincipal User user) {
        
        transactionService.deleteAllUserTransactions(user.getId());
        return ResponseEntity.ok(Map.of("message", "All transactions deleted successfully"));
    }
}
