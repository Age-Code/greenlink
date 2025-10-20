package org.example.greenlink.security;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.RefreshToken;
import org.example.greenlink.exception.InvalidTokenException;
import org.example.greenlink.repository.RefreshTokenRepository;
import org.springframework.stereotype.Service;

import java.util.Date;

@RequiredArgsConstructor
@Service
public class AuthServiceImpl implements AuthService {

	private final ExternalProperties externalProperties;
	private final RefreshTokenRepository refreshTokenRepository;

	// JWT 서명용 비밀 키 (HMAC512 알고리즘)
	@Override
	public Algorithm getTokenAlgorithm() {
		return Algorithm.HMAC512(externalProperties.getTokenSecretKey());
	}


	// Refresh Token 생성 (Claim <- UserId, DB 저장)
	@Override
	public String createRefreshToken(Long userId) {

		revokeRefreshToken(userId);

		String refreshToken = JWT.create()
				.withSubject("refreshToken")
				.withClaim("id", userId)
				.withExpiresAt(new Date(System.currentTimeMillis()+externalProperties.getRefreshTokenExpirationTime()))
				.sign(getTokenAlgorithm());

		refreshTokenRepository.save(RefreshToken.of(refreshToken, userId));
		return refreshToken;
	}

	// Refresh Token 검증
	@Override
	public Long verifyRefreshToken(String refreshToken) throws JWTVerificationException {

		refreshTokenRepository.findByToken(refreshToken)
				.orElseThrow(() -> new InvalidTokenException(""));

		return JWT.require(getTokenAlgorithm())
				.build()
				.verify(refreshToken)
				.getClaim("id").asLong();
	}

	// Refresh Token 삭제
	@Override
	public void revokeRefreshToken(Long userId) {
		refreshTokenRepository.deleteAll(refreshTokenRepository.findByUserId(userId));
	}

	// Access Token 발급
	@Override
	public String issueAccessToken(String refreshToken) throws JWTVerificationException {

		Long userId = verifyRefreshToken(refreshToken);

		String accessToken = createAccessToken(userId);

		return accessToken;
	}

	// AccessToken 생성 (Claim <- UserId)
	@Override
	public String createAccessToken(Long userId) {
    	return JWT.create()
 			 	  .withSubject("accessToken")
 			 	  .withClaim("id", userId)
 			 	  .withExpiresAt(new Date(System.currentTimeMillis()+externalProperties.getAccessTokenExpirationTime()))
 			 	  .sign(getTokenAlgorithm());
	}

	// Access Token 검증 (Claim -> UserId)
	@Override
	public Long verifyAccessToken(String accessToken) throws JWTVerificationException {
		return JWT.require(getTokenAlgorithm())
				.build()
				.verify(accessToken)
				.getClaim("id").asLong();
	}

}