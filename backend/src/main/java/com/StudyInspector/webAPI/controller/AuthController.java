package com.StudyInspector.webAPI.controller;

import com.StudyInspector.application.model.common.Role;
import com.StudyInspector.application.model.user.CourseTeacher;
import com.StudyInspector.application.model.user.LabTeacher;
import com.StudyInspector.application.repository.*;
import com.StudyInspector.webAPI.config.JWTGenerator;
import com.StudyInspector.webAPI.dto.LoginDto;
import com.StudyInspector.webAPI.dto.RegisterDto;
import com.StudyInspector.webAPI.responses.AuthResponseDto;
import com.StudyInspector.webAPI.responses.HttpResponseDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final CourseTeacherRepository courseTeacherRepository;
    private final LabTeacherRepository labTeacherRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JWTGenerator tokenGenerator;

    @Autowired
    public AuthController(AuthenticationManager authenticationManager, UserRepository userRepository, CourseTeacherRepository courseTeacherRepository, LabTeacherRepository labTeacherRepository,
                          RoleRepository roleRepository, PasswordEncoder passwordEncoder, JWTGenerator tokenGenerator) {
        this.authenticationManager = authenticationManager;
        this.userRepository = userRepository;
        this.courseTeacherRepository = courseTeacherRepository;
        this.labTeacherRepository = labTeacherRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenGenerator = tokenGenerator;
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@RequestBody LoginDto loginDto) {
        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginDto.getEmail(), loginDto.getPassword()));
        }
        catch (Exception e) {
            return new ResponseEntity<>(new AuthResponseDto("Invalid email or password"), HttpStatus.BAD_REQUEST);
        }
        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = tokenGenerator.generateToken(authentication);
        return new ResponseEntity<>(new AuthResponseDto(token), HttpStatus.OK);
    }

    @PostMapping("/register/courseTeacher")
    public ResponseEntity<HttpResponseDto> registerCourseTeacher(@RequestBody RegisterDto registerDto) {
        if(userRepository.existsByEmail(registerDto.getEmail())) {
            return new ResponseEntity<>(new HttpResponseDto(
                    "Email is already taken!"), HttpStatus.BAD_REQUEST);
        }
        CourseTeacher courseTeacher = new CourseTeacher();
        courseTeacher.setEmail(registerDto.getEmail());
        courseTeacher.setPassword(passwordEncoder.encode(registerDto.getPassword()));
        courseTeacher.setFirstName(registerDto.getFirstName());
        courseTeacher.setLastName(registerDto.getLastName());
        courseTeacher.setPhoneNumber(registerDto.getPhoneNumber());

        List<Role> roles = List.of(new Role[]{roleRepository.findByName("USER").get(), roleRepository.findByName("COURSE TEACHER").get(), roleRepository.findByName("LAB TEACHER").get()});
        courseTeacher.setRoles(roles);

        courseTeacherRepository.save(courseTeacher);

        return new ResponseEntity<>(new HttpResponseDto(
                "Course teacher registered successfully!",
                courseTeacher), HttpStatus.OK);
    }

    @PostMapping("/register/labTeacher")
    public ResponseEntity<HttpResponseDto> registerLabTeacher(@RequestBody RegisterDto registerDto) {
        if(userRepository.existsByEmail(registerDto.getEmail())) {
            return new ResponseEntity<>(new HttpResponseDto("Email is already taken!"),
                    HttpStatus.BAD_REQUEST);
        }
        LabTeacher labTeacher = new LabTeacher();
        labTeacher.setEmail(registerDto.getEmail());
        labTeacher.setPassword(passwordEncoder.encode(registerDto.getPassword()));
        labTeacher.setFirstName(registerDto.getFirstName());
        labTeacher.setLastName(registerDto.getLastName());
        labTeacher.setPhoneNumber(registerDto.getPhoneNumber());

        List<Role> roles = List.of(new Role[]{roleRepository.findByName("USER").get(), roleRepository.findByName("LAB TEACHER").get()});
        labTeacher.setRoles(roles);

        labTeacherRepository.save(labTeacher);

        return new ResponseEntity<>(new HttpResponseDto(
                "Lab teacher registered successfully!",
                labTeacher), HttpStatus.OK);
    }
}
