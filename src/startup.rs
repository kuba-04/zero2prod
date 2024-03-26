use std::net::TcpListener;

use actix_web::{App, HttpServer, web};
use actix_web::dev::Server;
use sqlx::{Pool, Postgres};

use crate::routes::{health_check, subscribe};

pub fn run(
    listener: TcpListener,
    connection_pool: Pool<Postgres>
) -> Result<Server, std::io::Error> {
    let connection = web::Data::new(connection_pool);
    let server = HttpServer::new(move || {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/subscriptions", web::post().to(subscribe))
            .app_data(connection.clone())
    })
        .listen(listener)?
        .run();
    Ok(server)
}