use crate::domain::subscriber_mail::SubscriberEmail;
pub use crate::domain::subscriber_name::SubscriberName;

pub struct NewSubscriber {
    pub email: SubscriberEmail,
    pub name: SubscriberName,
}