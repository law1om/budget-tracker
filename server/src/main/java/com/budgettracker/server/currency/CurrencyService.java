package com.budgettracker.server.currency;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.math.MathContext;
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

    // Количество десятичных знаков для отображения суммы по валютам
    private static final Map<String, Integer> SCALE_BY_CURRENCY = Map.of(
        "USD", 6,
        "EUR", 6,
        "KZT", 2
    );

    // Высокоточная математика с половинным округлением до четного для уменьшения систематической ошибки
    private static final MathContext MC = new MathContext(34, RoundingMode.HALF_EVEN);

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
        
        // Конвертация через USD с высоким уровнем точности и финальным округлением:
        // 1) from -> USD: amount / fromRate (без финального округления)
        // 2) USD -> to: result * toRate (без финального округления)
        // 3) Финальное округление по правилам валюты назначения
        BigDecimal inUsd = amount.divide(fromRate, MC);
        BigDecimal result = inUsd.multiply(toRate, MC);
        int scale = SCALE_BY_CURRENCY.getOrDefault(to, 2);
        return result.setScale(scale, RoundingMode.HALF_EVEN);
    }
}
