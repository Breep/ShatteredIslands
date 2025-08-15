class_name Furniture
extends StaticBody3D

enum FurnitureType {
	UNDEF,
	STATISTIC_BOARD,
	CARD_SHOP,
	ORACLE
}

@export var furniture_type: FurnitureType
