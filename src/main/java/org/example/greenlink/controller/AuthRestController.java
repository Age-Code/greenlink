package org.example.greenlink.controller;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.exception.InvalidTokenException;
import org.example.greenlink.exception.NoMatchingDataException;
import org.example.greenlink.security.AuthService;
import org.example.greenlink.security.ExternalProperties;
import org.example.greenlink.security.PrincipalDetails;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RequestMapping("/api/auth")
@RestController
public class AuthRestController {

    final ExternalProperties externalProperties;
    final AuthService authService;

    @PostMapping("")
    public ResponseEntity<Void> access(HttpServletRequest request) {
        String accessToken = null;
        String prefix = externalProperties.getTokenPrefix();
        String refreshToken = request.getHeader(externalProperties.getRefreshKey());

        if(refreshToken == null || !refreshToken.startsWith(prefix) || refreshToken.equals(prefix)) {
            throw new InvalidTokenException("No Prefix");
        }

        refreshToken = refreshToken.substring(prefix.length());
        accessToken = prefix + authService.issueAccessToken(refreshToken);

        return ResponseEntity.status(HttpStatus.OK).header(externalProperties.getAccessKey(), accessToken).build();
    }

    @DeleteMapping("")
    public ResponseEntity<Void> logout(@AuthenticationPrincipal PrincipalDetails principalDetails) {
        if(principalDetails == null || principalDetails.getUser() == null || principalDetails.getUser().getId() == null) {
            throw new NoMatchingDataException("No PrincipalDetails");
        }

        authService.revokeRefreshToken(principalDetails.getUser().getId());

        return ResponseEntity.status(HttpStatus.OK).build();
    }
}
