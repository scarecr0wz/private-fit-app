class FoodItem {
  final String id;
  final String name;
  final int caloriesPer100g;
  final double protein;
  final double carbs;
  final double fat;

  const FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

const dummyFoodDb = [
  FoodItem(
    id: '1',
    name: 'Nasi Putih',
    caloriesPer100g: 130,
    protein: 2.7,
    carbs: 28.1,
    fat: 0.3,
  ),
  FoodItem(
    id: '2',
    name: 'Dada Ayam Panggang',
    caloriesPer100g: 165,
    protein: 31.0,
    carbs: 0.0,
    fat: 3.6,
  ),
  FoodItem(
    id: '3',
    name: 'Ayam Goreng',
    caloriesPer100g: 246,
    protein: 23.0,
    carbs: 7.8,
    fat: 13.6,
  ),
  FoodItem(
    id: '4',
    name: 'Telur Rebus',
    caloriesPer100g: 155,
    protein: 13.0,
    carbs: 1.1,
    fat: 11.0,
  ),
  FoodItem(
    id: '5',
    name: 'Tempe Goreng',
    caloriesPer100g: 220,
    protein: 14.0,
    carbs: 12.0,
    fat: 11.5,
  ),
  FoodItem(
    id: '6',
    name: 'Pisang',
    caloriesPer100g: 89,
    protein: 1.1,
    carbs: 23.0,
    fat: 0.3,
  ),
  FoodItem(
    id: '7',
    name: 'Roti Gandum',
    caloriesPer100g: 247,
    protein: 9.0,
    carbs: 41.0,
    fat: 3.4,
  ),
  FoodItem(
    id: '8',
    name: 'Oatmeal',
    caloriesPer100g: 389,
    protein: 17.0,
    carbs: 66.0,
    fat: 7.0,
  ),
  FoodItem(
    id: '9',
    name: 'Susu Full Cream',
    caloriesPer100g: 61,
    protein: 3.2,
    carbs: 4.8,
    fat: 3.3,
  ),
  FoodItem(
    id: '10',
    name: 'Tahu Goreng',
    caloriesPer100g: 175,
    protein: 11.0,
    carbs: 5.0,
    fat: 12.0,
  ),
  FoodItem(
    id: '11',
    name: 'Mie Goreng',
    caloriesPer100g: 190,
    protein: 4.5,
    carbs: 26.0,
    fat: 8.0,
  ),
  FoodItem(
    id: '12',
    name: 'Salad Ayam',
    caloriesPer100g: 95,
    protein: 12.0,
    carbs: 4.5,
    fat: 3.5,
  ),
];
