﻿    #Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс

#Область ЗагрузкаИзФайлаВТЧ

// Переопределяет параметры загрузки данных из файла.
//
// Параметры:
//  Параметры - Структура:
//   * ИмяМакетаСШаблоном - Строка - наименование макета. Например, "ЗагрузкаИзФайла".
//   * ИмяТабличнойЧасти - Строка - Полное имя табличной части. 
//   *  Например, "Документ._ДемоСчетНаОплатуПокупателю.ТабличнаяЧасть.Товары"
//   * ОбязательныеКолонки - Массив из Строка - наименования обязательных для заполнения колонок.
//   * ТипДанныхКолонки - Соответствие из КлючИЗначение:
//      * Ключ - Строка - имя колонки;
//      * Значение - ОписаниеТипов - тип колонки загружаемых данных.
//   * ДополнительныеПараметры - Структура
//
Процедура УстановитьПараметрыЗагрузкиИзФайлаВТЧ(Параметры) Экспорт

КонецПроцедуры

#КонецОбласти
#КонецОбласти 
#КонецЕсли