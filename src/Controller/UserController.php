<?php

namespace App\Controller;

use Exception;
use App\Entity\User;
use Doctrine\Persistence\ManagerRegistry;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class UserController extends AbstractController
{

    #[Route('/api/user/{id}', name: 'api_get_user', methods: ['GET'])]
    public function getCurrentUser(string $id, ManagerRegistry $doctrine, ): Response
    {

        $entityManager = $doctrine->getManager();

        error_log('===========================> Erreur loggé ');

        $user = $entityManager->getRepository(User::class)->findOneBy(['email'=>$id]);

        if (!$user) {
            return $this->json(['message' => 'id inconnu'], 404);
        }

        return $this->json([
            'id' => $user->getId(),
            'email' => $user->getEmail(),
            'firstname' => $user->getFirstname(),
            'lastname' => $user->getLastname(),
            'roles' => $user->getRoles()
        ], 200);

    }

    #[Route('/api/user', name: 'api_put_user', methods: ['PUT'])]
    public function putUser(ManagerRegistry $doctrine, Request $request): JsonResponse
    {

        $payload = json_decode(urldecode($request->getContent()), true);

        $entityManager = $doctrine->getManager();

        $user = $entityManager->getRepository(User::class)->find($payload['id']);

        if (!$user) {
            return $this->json(['message' => 'user non trouvé'], 404);
        }

        $user->setEmail($payload['email']);
//        $user->setPassword($this->userPasswordHasher->hashPassword($user, $payload['password']));
        $user->setFirstname($payload['firstname']);
        $user->setLastname($payload['lastname']);
        $user->setRoles($payload['roles']);
        
        try {
            $entityManager->flush();
        } catch (Exception $e) {
            error_log(($e));
            return $this->json(['message' => 'Erreur d\'acces a la base. Code : '.$e->getCode()], 503);
        }
 
        return $this->json(['message' => 'Modifications enregistrées'], 200);

    }

    #[Route('/api/user/{id}', name: 'api_delete_user', methods: ['DELETE'])]
    public function deleteUser($id, ManagerRegistry $doctrine, Request $request): JsonResponse
    {

        $entityManager = $doctrine->getManager();

        $user = $entityManager->getRepository(User::class)->find($id);

        if (!$user) {
            return $this->json(['message' => 'user non trouvé'], 404);
        }

        $repository = $entityManager->getRepository(User::class);
        $user = $repository->find($id);
        $repository->remove($user);
        $entityManager->flush();

        return $this->json(['message' => 'delete effecuté'], 200);

    }

    #[Route('/api/users', name: 'api_get_users', methods: ['GET'])]
    public function getUsers(ManagerRegistry $doctrine): JsonResponse
    {

        $entityManager = $doctrine->getManager();

        error_log('===========================> Erreur loggé ');

        $users = $entityManager->getRepository(User::class)->findAll();

        if (!$users) {
            return $this->json(['message' => 'Erreur lecture users'], 404);
        }

        $usersArray = [];

        foreach($users as $user) {
            error_log('===========================> Erreur loggé '.$user->getEmail());
            array_push($usersArray,
            [
                'id' => $user->getId(),
                'email' => $user->getEmail(),
                'firstname' => $user->getFirstname(),
                'lastname' => $user->getLastname(),
                'roles' => $user->getRoles()
            ]);

        }

        return $this->json($usersArray, 200, ['Content-Type' => 'application/json;charset=UTF-8']);

    }

    #[Route('/api/users/{page}/{number}', name: 'api_get_users_page', methods: ['GET'])]
    public function getUsersPage(int $page, int $number, ManagerRegistry $doctrine): JsonResponse
    {

        $entityManager = $doctrine->getManager();

        error_log('===========================> Erreur loggé ');

        $countUsers = $entityManager->getRepository(User::class)->createQueryBuilder('u')
        ->select('count(u.id)')
        ->getQuery()
        ->getSingleScalarResult();

        $users = $entityManager->getRepository(User::class)->findBy([], ['email' => 'ASC'], $number, ($page - 1) * $number);

        if (!$users) {
            return $this->json(['message' => 'Erreur lecture users'], 404);
        }

        $usersArray = [];

        foreach($users as $user) {
            error_log('===========================> Erreur loggé '.$user->getEmail());
            array_push($usersArray,
            [
                'id' => $user->getId(),
                'email' => $user->getEmail(),
                'firstname' => $user->getFirstname(),
                'lastname' => $user->getLastname(),
                'roles' => $user->getRoles()
            ]);

        }

        return $this->json([
                'countUsers' => $countUsers,
                'usersPage' => $usersArray
            ], 
            200, 
            ['Content-Type' => 'application/json;charset=UTF-8']
        );

    }

}
