package com.budgettracker.server.user.dto;

import jakarta.validation.constraints.DecimalMin;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class UserUpdateRequest {
    private String name;

    @DecimalMin(value = "0.0", inclusive = true)
    private BigDecimal balance;

    private String currency;
}
