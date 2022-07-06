﻿
#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура гф_ПриОткрытииПосле(Отказ)
	
	Форма = ЭтотОбъект;
	
	ФормаВладелец = Форма.ВладелецФормы;
    Пока ТипЗнч(ФормаВладелец) <> Тип("ФормаКлиентскогоПриложения") Цикл
        ФормаВладелец = ФормаВладелец.Родитель; 
    КонецЦикла;
		
	Попытка
		ОбъектФормыВладельца = ФормаВладелец.Объект;
	Исключение
		Возврат;
	КонецПопытки;	
		
	Если ОбъектФормыВладельца.Свойство("Организация") Тогда
		
		Если ЗначениеЗаполнено(ОбъектФормыВладельца.Организация) Тогда
			ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Ссылка.гф_Организация",
									ОбъектФормыВладельца.Организация, ВидСравненияКомпоновкиДанных.Равно, , Истина);
			Элементы.Список.Отображение = ОтображениеТаблицы.Список;
		Иначе
	
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Поле """ + ФормаВладелец.Элементы.Организация.Имя + """ не заполнено!";
			Сообщение.Поле = "ОбъектФормыВладельца.Организация";
			Сообщение.ПутьКДанным = "";
			Сообщение.УстановитьДанные(ОбъектФормыВладельца);
			Сообщение.Сообщить();
			
			Форма.Закрыть();
			
		КонецЕсли;	
		
	КонецЕсли; 
	
КонецПроцедуры

#КонецОбласти