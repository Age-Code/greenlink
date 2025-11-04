package org.example.greenlink.security;

import lombok.RequiredArgsConstructor;
import org.example.greenlink.domain.User;
import org.example.greenlink.exception.NoMatchingDataException;
import org.example.greenlink.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class PrincipalDetailsService implements UserDetailsService {
	
	private final UserRepository userRepository;
	
    /**
	 *  principalDetails 생성 (username)
	 */
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		User user = userRepository.findByUsername(username).orElse(null);

		if(user == null) {
			throw new NoMatchingDataException("NoMatchData username: " + username);
		}

		return new PrincipalDetails(user);
	}
	
}