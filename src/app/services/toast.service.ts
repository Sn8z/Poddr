import { Injectable } from "@angular/core";

@Injectable({
  providedIn: "root"
})
export class ToastService {

  constructor() { }

  info(msg: String = "Hello there!") {
    //toast({
    //  message: msg,
    //  type: "is-success",
    //  dismissible: false,
    //  duration: 5000,
    //  pauseOnHover: true,
    //  animate: { in: "fadeIn", out: "fadeOut" }
    //});
  }

  error(error: String = "Error :(") {
    //toast({
    //  message: error,
    //  type: "is-danger",
    //  dismissible: false,
    //  duration: 5000,
    //  pauseOnHover: true,
    //  animate: { in: "fadeIn", out: "fadeOut" }
    //});
  }
}
