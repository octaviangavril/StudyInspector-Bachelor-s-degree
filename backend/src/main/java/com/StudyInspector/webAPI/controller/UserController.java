package com.StudyInspector.webAPI.controller;

import com.StudyInspector.webAPI.dto.UserDto;
import com.StudyInspector.application.model.user.UserEntity;
import com.StudyInspector.application.repository.UserRepository;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserController(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/all")
    public ResponseEntity<HttpResponseDto> getAllUsers() {
        return new ResponseEntity<>(new HttpResponseDto("Users found",
                userRepository.findAll()), HttpStatus.OK);
    }

    @GetMapping("/get")
    public ResponseEntity<HttpResponseDto> getUserByEmail(@RequestParam String email) {
        UserEntity user = userRepository.findByEmail(email).orElse(null);
        if (user != null) {
            return new ResponseEntity<>(new HttpResponseDto("User found",
                    user), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("User not found"),
                HttpStatus.NOT_FOUND);
    }

    @GetMapping("/getById")
    public ResponseEntity<HttpResponseDto> getUserById(@RequestParam Long id) {
        UserEntity user = userRepository.findById(id).orElse(null);
        if (user != null) {
            return new ResponseEntity<>(new HttpResponseDto("User found",
                    user), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("User not found"),
                HttpStatus.NOT_FOUND);
    }

    @PutMapping("/update")
    public ResponseEntity<HttpResponseDto> updateUser(@RequestParam Long id, @RequestBody UserDto user) {
        UserEntity userToUpdate = userRepository.findById(id).orElse(null);
        if (userToUpdate != null) {
            if ((user.getEmail() == null || user.getEmail().isEmpty())
                    && (user.getPassword() == null || user.getPassword().isEmpty())
                    && (user.getFirstName() == null || user.getFirstName().isEmpty())
                    && (user.getLastName() == null || user.getLastName().isEmpty())
                    && (user.getPhoneNumber() == null || user.getPhoneNumber().isEmpty())) {

                return new ResponseEntity<>(new HttpResponseDto("No data to update"),
                        HttpStatus.BAD_REQUEST);
            }
            if (user.getEmail() != null && !user.getEmail().isEmpty()) {
                userToUpdate.setEmail(user.getEmail());
            }
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                userToUpdate.setPassword(passwordEncoder.encode(user.getPassword()));
            }
            if (user.getFirstName() != null && !user.getFirstName().isEmpty()) {
                userToUpdate.setFirstName(user.getFirstName());
            }
            if (user.getLastName() != null && !user.getLastName().isEmpty()) {
                userToUpdate.setLastName(user.getLastName());
            }
            if (user.getPhoneNumber() != null && !user.getPhoneNumber().isEmpty()) {
                userToUpdate.setPhoneNumber(user.getPhoneNumber());
            }
            userRepository.save(userToUpdate);
            return new ResponseEntity<>(new HttpResponseDto("User updated successfully",
                    userToUpdate), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("User not found"),
                HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/delete")
    public ResponseEntity<HttpResponseDto> deleteUser(@RequestParam Long id) {
        UserEntity user = userRepository.findById(id).orElse(null);
        if (user != null) {
            userRepository.delete(user);
            return new ResponseEntity<>(new HttpResponseDto("User deleted successfully",
                    user), HttpStatus.OK);
        }
        return new ResponseEntity<>(new HttpResponseDto("User not found"),
                HttpStatus.NOT_FOUND);
    }
}
