<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\News;
use App\Models\Comment;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create admin user
        $admin = User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
        ]);

        // Create regular users
        $users = User::factory(5)->create();

        // Create news by admin
        $adminNews = News::factory(10)->create([
            'user_id' => $admin->id,
        ]);

        // Create news by other users
        $userNews = News::factory(15)->create();

        // Create comments for each news
        $allNews = News::all();
        foreach ($allNews as $news) {
            // Admin comments on some news
            if (fake()->boolean(70)) {
                Comment::factory()->create([
                    'user_id' => $admin->id,
                    'news_id' => $news->id,
                ]);
            }

            // Other users comment
            Comment::factory(rand(2, 8))->create([
                'news_id' => $news->id,
                'user_id' => $users->random()->id,
            ]);
        }
    }
}
