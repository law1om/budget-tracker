package com.budgettracker.server.user;

import com.budgettracker.server.user.dto.UserUpdateRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/me")
    public ResponseEntity<User> me(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(user);
    }

    @PutMapping("/me")
    public ResponseEntity<User> updateMe(@AuthenticationPrincipal User user,
                                         @Valid @RequestBody UserUpdateRequest request) {
        if (request.getName() != null) user.setName(request.getName());
        if (request.getBalance() != null) user.setBalance(request.getBalance());
        if (request.getCurrency() != null) user.setCurrency(request.getCurrency());
        userRepository.save(user);
        return ResponseEntity.ok(user);
    }
}
