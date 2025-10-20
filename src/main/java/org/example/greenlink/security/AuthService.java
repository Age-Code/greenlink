package org.example.greenlink.security;

import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;

public interface AuthService {
	
	Algorithm getTokenAlgorithm();
	String createRefreshToken(Long userId);
	Long verifyRefreshToken(String refreshToken) throws JWTVerificationException;
	void revokeRefreshToken(Long userId);
	String issueAccessToken(String refreshToken) throws JWTVerificationException;
	String createAccessToken(Long userId);
	Long verifyAccessToken(String accessToken) throws JWTVerificationException;

}