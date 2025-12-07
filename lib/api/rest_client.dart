import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sori/constants.dart';
import 'package:sori/models/token.dart';
import 'package:sori/models/user.dart';
import 'package:sori/models/workspace.dart';
import 'package:sori/models/folder.dart';
import 'package:sori/models/note.dart';
import 'package:sori/models/server.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // Auth
  @POST("/auth/refresh")
  Future<Token> refreshToken();

  @GET("/auth/{provider_name}")
  Future<void> startOAuth(
    @Path("provider_name") String providerName,
    @Query("redirect") String redirect,
  );

  @GET("/auth/{provider_name}/callback")
  Future<void> oauthCallback(@Path("provider_name") String providerName);

  // User
  @GET("/user")
  Future<User> getUser();

  @PATCH("/user")
  Future<User> updateUser(@Body() Map<String, dynamic> body);

  // Workspace
  @GET("/workspace")
  Future<WorkspaceListResponse> getWorkspaces({
    @Query("cursor") String? cursor,
    @Query("limit") int? limit,
    @Query("sortBy") String? sortBy,
    @Query("orderBy") String? orderBy,
  });

  @POST("/workspace")
  Future<Workspace> createWorkspace(@Body() Map<String, dynamic> body);

  @GET("/workspace/{workspace_id}")
  Future<Workspace> getWorkspace(@Path("workspace_id") String workspaceId);

  // Folder
  @POST("/workspace/{workspace_id}/folder")
  Future<Folder> createFolder(
    @Path("workspace_id") String workspaceId,
    @Body() Map<String, dynamic> body,
  );

  @GET("/workspace/{workspace_id}/folder")
  Future<List<Folder>> getFolders(@Path("workspace_id") String workspaceId);

  @PATCH("/workspace/{workspace_id}/folder/{folder_id}")
  Future<Folder> updateFolder(
    @Path("workspace_id") String workspaceId,
    @Path("folder_id") String folderId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("/workspace/{workspace_id}/folder/{folder_id}")
  Future<void> deleteFolder(
    @Path("workspace_id") String workspaceId,
    @Path("folder_id") String folderId,
  );

  // Note
  @POST("/workspace/{workspace_id}/note")
  Future<Note> createNote(
    @Path("workspace_id") String workspaceId,
    @Body() Map<String, dynamic> body,
  );

  @GET("/workspace/{workspace_id}/note/{note_id}")
  Future<Note> getNote(
    @Path("workspace_id") String workspaceId,
    @Path("note_id") String noteId,
  );

  @GET("/workspace/{workspace_id}/note")
  Future<List<Note>> getNotes(@Path("workspace_id") String workspaceId);

  @PATCH("/workspace/{workspace_id}/note/{note_id}")
  Future<Note> updateNote(
    @Path("workspace_id") String workspaceId,
    @Path("note_id") String noteId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("/workspace/{workspace_id}/note/{note_id}")
  Future<void> deleteNote(
    @Path("workspace_id") String workspaceId,
    @Path("note_id") String noteId,
  );

  // Server
  @POST("/server")
  Future<PublicServer> createServer(@Body() Map<String, dynamic> body);

  @GET("/server")
  Future<ServerListResponse> getServers({
    @Query("cursor") String? cursor,
    @Query("limit") int? limit,
    @Query("sortBy") String? sortBy,
    @Query("orderBy") String? orderBy,
  });

  @GET("/server/{server_id}")
  Future<PublicServer> getServer(@Path("server_id") String serverId);

  @PATCH("/server/{server_id}")
  Future<PublicServer> updateServer(
    @Path("server_id") String serverId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE("/server/{server_id}")
  Future<void> deleteServer(@Path("server_id") String serverId);
}

class WorkspaceListResponse {
  final List<Workspace> items;
  WorkspaceListResponse({required this.items});

  factory WorkspaceListResponse.fromJson(Map<String, dynamic> json) {
    return WorkspaceListResponse(
      items: (json['items'] as List).map((e) => Workspace.fromJson(e)).toList(),
    );
  }
}

class ServerListResponse {
  final List<PublicServer> items;
  ServerListResponse({required this.items});

  factory ServerListResponse.fromJson(Map<String, dynamic> json) {
    return ServerListResponse(
      items: (json['items'] as List)
          .map((e) => PublicServer.fromJson(e))
          .toList(),
    );
  }
}
