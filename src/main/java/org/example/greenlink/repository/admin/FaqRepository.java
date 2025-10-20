package org.example.greenlink.repository.admin;

import org.example.greenlink.domain.admin.Faq;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FaqRepository extends JpaRepository<Faq, Long> {
}
