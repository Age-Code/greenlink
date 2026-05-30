package com.greenlink.greenlink.repository;

import com.greenlink.greenlink.domain.item.Item;
import com.greenlink.greenlink.domain.item.ItemType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ItemRepository extends JpaRepository<Item, Long> {

    List<Item> findAllByDeletedFalse();

    List<Item> findAllByItemTypeAndDeletedFalse(ItemType itemType);

    Optional<Item> findByIdAndDeletedFalse(Long id);

    Optional<Item> findByNameAndDeletedFalse(String name);

    boolean existsByNameAndDeletedFalse(String name);
}