package com.budgettracker.server.currency;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/api/currency")
public class CurrencyController {

    private final CurrencyService currencyService;

    public CurrencyController(CurrencyService currencyService) {
        this.currencyService = currencyService;
    }

    @GetMapping("/convert")
    public ResponseEntity<Map<String, Object>> convert(@RequestParam("amount") BigDecimal amount,
                                                       @RequestParam("from") String from,
                                                       @RequestParam("to") String to) {
        BigDecimal result = currencyService.convert(amount, from, to);
        return ResponseEntity.ok(Map.of(
                "amount", amount,
                "from", from,
                "to", to,
                "result", result
        ));
    }
}
