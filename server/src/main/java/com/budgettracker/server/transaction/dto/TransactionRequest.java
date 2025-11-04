package com.budgettracker.server.transaction.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TransactionRequest {
    
    @NotBlank(message = "Title is required")
    private String title;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;
    
    @NotNull(message = "Date is required")
    private LocalDateTime date;
    
    @NotBlank(message = "Category ID is required")
    private String categoryId;
    
    @NotBlank(message = "Type is required")
    private String type; // income или expense
}
