<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\News>
 */
class NewsFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $categories = ['Politik', 'Ekonomi', 'Teknologi', 'Olahraga', 'Entertainment', 'Pendidikan', 'Kesehatan'];
        
        return [
            'user_id' => User::factory(),
            'title' => fake()->sentence(6),
            'content' => fake()->paragraphs(5, true),
            'image' => 'https://picsum.photos/800/600?random=' . fake()->numberBetween(1, 1000),
            'category' => fake()->randomElement($categories),
            'is_published' => true,
        ];
    }
}
