package com.budgettracker.server.currency;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;

/**
 * Сервис конвертации валют с фиксированными курсами
 */
@Service
public class CurrencyService {
    
    // Курсы валют относительно USD
    // 1 USD = X единиц валюты
    private static final Map<String, BigDecimal> USD_RATES = Map.of(
        "USD", new BigDecimal("1.0"),
        "EUR", new BigDecimal("0.86"),
        "KZT", new BigDecimal("535.0")
    );

    /**
     * Конвертация суммы из одной валюты в другую
     * 
     * @param amount сумма для конвертации
     * @param from исходная валюта (KZT, USD, EUR)
     * @param to целевая валюта (KZT, USD, EUR)
     * @return сконвертированная сумма
     */
    public BigDecimal convert(BigDecimal amount, String from, String to) {
        // Если валюты одинаковые, возвращаем исходную сумму
        if (from.equals(to)) {
            return amount;
        }
        
        // Получаем курсы валют
        BigDecimal fromRate = USD_RATES.get(from);
        BigDecimal toRate = USD_RATES.get(to);
        
        if (fromRate == null || toRate == null) {
            throw new RuntimeException("Неподдерживаемая валюта: " + from + " или " + to);
        }
        
        // Конвертация через USD:
        // 1. Конвертируем from -> USD: amount / fromRate
        // 2. Конвертируем USD -> to: result * toRate
        BigDecimal inUsd = amount.divide(fromRate, 10, RoundingMode.HALF_UP);
        return inUsd.multiply(toRate).setScale(4, RoundingMode.HALF_UP);
    }
}
