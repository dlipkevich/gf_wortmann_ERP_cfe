﻿#Если Сервер Тогда
	
#Область ПрограммныйИнтерфейс

// Возвращает сведения о внешней обработке.
//
// Возвращаемое значение:
// Структура - Подробнее см. ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке().
//
Функция СведенияОВнешнейОбработке() Экспорт
	
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке();
    ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка();
	
	ПараметрыРегистрации.Версия = "1.7";
	
	ПараметрыРегистрации.Наименование =  Метаданные().Представление();
	
	Команда = ПараметрыРегистрации.Команды.Добавить();
	Команда.Идентификатор = Метаданные().Имя;
    Команда.Представление = ПараметрыРегистрации.Наименование;
    Команда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	
	Возврат ПараметрыРегистрации;
	
КонецФункции

#КонецОбласти

#КонецЕсли