import { Injectable } from "@angular/core";
import Swal from 'sweetalert2';

@Injectable({
  providedIn: "root"
})
export class ToastService {

  constructor() { }

  info(msg: string = "Hello there!"): void {
    Swal.fire({
      toast: true,
      text: msg,
      position: 'top-end',
      showConfirmButton: false,
      timer: 5000,
      animation: true,
      background: "var(--third-bg-color)"
    })
  }

  success(msg: string = "Something went well."): void {
    Swal.fire({
      type: 'success',
      text: msg,
      showConfirmButton: false
    });
  }

  error(error: string = "Something went wrong."): void {
    Swal.fire({
      type: 'error',
      text: error,
      showConfirmButton: false
    });
  }

  message(msg: string = ""): void {
    Swal.fire({
      title: "Episode description",
      text: msg,
      background: 'var(--third-bg-color)',
      showConfirmButton: false
    });
  }
}
