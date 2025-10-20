package com.budgettracker.server.currency.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class CurrencyConvertRequest {
    @NotNull
    private BigDecimal amount;

    @NotBlank
    private String from;

    @NotBlank
    private String to;
}
