# Тестовый пример сервера для проверки конекта
import socket
import sys
import threading


def clientthreaded(сonnect, addr):
    # Читаем сообщение отправленое от брайзер к сервер
    ind = 1
    while True:
        ind = ind + 1
        try:
            indata = сonnect.recv(32768)
            if len(indata) == 0:
               break
        except Exception:
            break
        else:
            str = 'inData=%s\r\n%s\r\n' % (ind, indata.decode('cp1251'))
            print(ind)
            # print('utf-8',indata.decode('utf-8'))
            # print('ascii', indata.decode('ascii'))
            print('cp1251', indata.decode('cp1251'))
            сonnect.send(str.encode('cp1251'))
    сonnect.close()


port = 8080
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind(("", port))
sock.listen(5)
count = 0
while True:
    сonnect, addr = sock.accept()
    print('Connected to :', addr[0], ':', addr[1])
    t1 = threading.Thread(target=clientthreaded, args=(сonnect, addr,))
    t1.start()
    count = count + 1
    print('count:', count)
s.close()
