﻿#Область ОбработчикиСобытийФормы   

// #wortmann {
// Устанавлиевает значения  поля Активный в зависимости от предопределенных данных 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/08/30   
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СтатусДействующий=ОбщегоНазначения.ПредопределенныйЭлемент("Справочник.гф_СтатусыЛимитов.Действующий"); 
	СтатусПриостановлен=ОбщегоНазначения.ПредопределенныйЭлемент("Справочник.гф_СтатусыЛимитов.Приостановлен");
	
	Если СтатусДействующий.Наименование=Объект.Наименование Или СтатусПриостановлен.Наименование=Объект.Наименование Тогда  
	     Объект.Активный=Истина;	
	 КонецЕсли;
	 
	 ЭтаФорма.Записать();
	 
КонецПроцедуры
// } #wortmann

#КонецОбласти
