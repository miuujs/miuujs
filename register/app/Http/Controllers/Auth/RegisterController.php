<?php

namespace Pterodactyl\Http\Controllers\Auth;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Pterodactyl\Models\User;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Services\Users\UserCreationService;

class RegisterController extends Controller
{
    public function __construct(
        protected SettingsRepositoryInterface $settings,
        protected UserCreationService $creationService
    ) {}

    public function register(Request $request): JsonResponse
    {
        $enabled = $this->settings->get('pterodactyl:auth:register:enabled', '0');
        if ($enabled !== '1') {
            return new JsonResponse(['error' => 'Registration is currently disabled.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'email' => 'required|email|max:255|unique:users',
            'username' => 'required|string|min:3|max:255|unique:users|alpha_num',
            'name_first' => 'required|string|max:255',
            'name_last' => 'required|string|max:255',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return new JsonResponse(['error' => $validator->errors()->first()], 422);
        }

        try {
            $user = $this->creationService->handle([
                'email' => $request->input('email'),
                'username' => $request->input('username'),
                'name_first' => $request->input('name_first'),
                'name_last' => $request->input('name_last'),
                'password' => $request->input('password'),
                'root_admin' => false,
            ]);

            $requireEmail = $this->settings->get('pterodactyl:auth:register:require_email_verification', '0');
            if ($requireEmail === '1') {
                $user->update(['email_verified_at' => null]);
            } else {
                $user->update(['email_verified_at' => now()]);
            }

            return new JsonResponse([
                'message' => 'Account created successfully. You can now log in.',
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'username' => $user->username,
                ],
            ]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Failed to create account. Please try again.'], 500);
        }
    }
}
