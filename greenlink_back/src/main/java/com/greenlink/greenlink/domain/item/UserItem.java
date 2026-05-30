package com.greenlink.greenlink.domain.item;

import com.greenlink.greenlink.common.BaseEntity;
import com.greenlink.greenlink.domain.plant.UserPlant;
import com.greenlink.greenlink.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Entity
@Table(name = "user_item")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 아이템을 보유한 사용자
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // 어떤 아이템인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private Item item;

    // 화분 장착 또는 영양제 사용 대상 식물
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_plant_id")
    private UserPlant userPlant;

    // OWNED, EQUIPPED, USED
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private UserItemStatus status;

    private UserItem(User user, Item item, UserItemStatus status) {
        this.user = user;
        this.item = item;
        this.status = status;
    }

    public static UserItem createOwned(User user, Item item) {
        return new UserItem(user, item, UserItemStatus.OWNED);
    }

    public boolean isOwner(User user) {
        return this.user.getId().equals(user.getId());
    }

    public boolean isOwned() {
        return this.status == UserItemStatus.OWNED && !this.isDeleted();
    }

    public boolean isEquipped() {
        return this.status == UserItemStatus.EQUIPPED && !this.isDeleted();
    }

    public boolean isUsed() {
        return this.status == UserItemStatus.USED && !this.isDeleted();
    }

    public void useSeed() {
        validateItemType(ItemType.SEED);
        validateOwned();

        this.status = UserItemStatus.USED;
        this.userPlant = null;
    }

    public void equipPot(UserPlant userPlant) {
        validateItemType(ItemType.POT);
        validateOwned();

        this.userPlant = userPlant;
        this.status = UserItemStatus.EQUIPPED;
    }

    public void unequipPot() {
        validateItemType(ItemType.POT);

        if (this.status != UserItemStatus.EQUIPPED) {
            throw new IllegalStateException("장착 중인 화분만 해제할 수 있습니다.");
        }

        this.userPlant = null;
        this.status = UserItemStatus.OWNED;
    }

    public void useNutrient(UserPlant userPlant) {
        validateItemType(ItemType.NUTRIENT);
        validateOwned();

        this.userPlant = userPlant;
        this.status = UserItemStatus.USED;
    }

    private void validateOwned() {
        if (this.status != UserItemStatus.OWNED) {
            throw new IllegalStateException("보유 중인 아이템만 사용할 수 있습니다.");
        }

        if (this.isDeleted()) {
            throw new IllegalStateException("삭제된 아이템은 사용할 수 없습니다.");
        }
    }

    private void validateItemType(ItemType requiredType) {
        if (this.item.getItemType() != requiredType) {
            throw new IllegalStateException(requiredType + " 타입의 아이템이 아닙니다.");
        }
    }
}